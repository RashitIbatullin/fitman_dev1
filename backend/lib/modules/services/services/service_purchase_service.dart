import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/modules/services/repositories/service_purchase_repository.dart';
import 'package:fitman_backend/modules/services/repositories/service_repository.dart';
import 'package:fitman_backend/modules/services/services/quota_period_calculator.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

/// Оформление услуги, остатки и история покупок.
///
/// FitMan не принимает деньги: покупка фиксирует факт оплаты
/// (`payment_source`, `payment_status`), проводок по счёту нет.
class ServicePurchaseService {
  ServicePurchaseService(
    this._purchaseRepository,
    this._serviceRepository,
    this._database,
  );

  final ServicePurchaseRepository _purchaseRepository;
  final ServiceRepository _serviceRepository;
  final Database _database;
  final AuditService _auditService = const AuditService();

  /// Оформляет услугу клиенту: покупка, участник, первый период квоты и аудит
  /// в одной транзакции.
  Future<ServicePurchase> create({
    required String clientId,
    required String serviceId,
    int? paymentSource,
    int? paymentStatus,
    double? discount,
    double? discountPercent,
    required AuditContext audit,
  }) {
    return _database.runTx((session) async {
      final client = await _purchaseRepository.getClientRow(
        clientId,
        session: session,
      );
      if (client == null) {
        throw const NotFoundException('Клиент не найден');
      }
      if (client['archived_at'] != null) {
        throw const ConflictException('Клиент находится в архиве');
      }

      final service = await _serviceRepository.getById(
        serviceId,
        session: session,
      );
      if (service == null) {
        throw const NotFoundException('Услуга не найдена');
      }
      if (!service.isActive || service.archivedAt != null) {
        throw const ConflictException('Услуга снята с продажи');
      }
      if (!service.allowStacking) {
        final exists = await _purchaseRepository.hasActivePurchase(
          clientId: clientId,
          serviceId: serviceId,
          session: session,
        );
        if (exists) {
          throw const ConflictException(
            'У клиента уже есть действующая покупка этой услуги',
          );
        }
      }

      final discountAmount = discount ?? 0;
      final percent = discountPercent ?? 0;
      if (discountAmount < 0) {
        throw const ValidationException('Скидка не может быть отрицательной');
      }
      if (percent < 0 || percent > 100) {
        throw const ValidationException('Скидка в процентах должна быть 0–100');
      }

      final basePrice = service.basePrice;
      final finalPrice = _finalPrice(
        basePrice: basePrice,
        discountAmount: discountAmount,
        discountPercent: percent,
      );

      final now = DateTime.now();
      final immediate = !service.activationRequired;
      final activationDate = immediate ? now : null;
      final expiryDate = immediate && service.durationDays != null
          ? now.add(Duration(days: service.durationDays!))
          : null;

      final totalUses =
          service.usageLimitMode == ServiceUsageLimitMode.unlimited
              ? null
              : service.maxUses;

      final source = paymentSource ?? ServicePaymentSource.none;
      final status = paymentStatus ??
          (source == ServicePaymentSource.none
              ? ServicePaymentStatus.notRequired
              : ServicePaymentStatus.paid);

      final purchaseId = await _purchaseRepository.createPurchase(
        clientId: clientId,
        serviceId: serviceId,
        soldBy: audit.actorId ?? '',
        purchasePrice: basePrice,
        discountPercent: percent,
        discountAmount: discountAmount,
        finalPrice: finalPrice,
        paymentStatus: status,
        paymentSource: paymentSource,
        purchaseDate: now,
        activationDate: activationDate,
        expiryDate: expiryDate,
        actualExpiryDate: expiryDate,
        totalUses: totalUses,
        status: immediate
            ? ServicePurchaseStatus.active
            : ServicePurchaseStatus.draft,
        session: session,
      );

      await _purchaseRepository.addParticipant(
        purchaseId: purchaseId,
        clientId: clientId,
        createdBy: audit.actorId ?? '',
        session: session,
      );

      // Периоды квоты нарезаются сразу на весь срок: закрытие периода —
      // это календарная граница, отдельная задача её не двигает.
      if (immediate &&
          service.usageLimitMode == ServiceUsageLimitMode.quota &&
          service.quotaLimit != null) {
        await _createQuotaPeriods(
          purchaseId: purchaseId,
          activation: now,
          expiry: expiryDate,
          quotaPeriod: service.quotaPeriod,
          quotaLimit: service.quotaLimit!,
          session: session,
        );
      }

      final purchase = await _purchaseRepository.getById(
        purchaseId,
        session: session,
      );
      if (purchase == null) {
        throw const NotFoundException('Покупка не найдена после создания');
      }

      await _auditService.record(
        session: session,
        tableName: 'service_purchases',
        rowPk: purchaseId,
        action: 'INSERT',
        context: audit,
        newValues: purchase.toJson(),
      );

      appLog.info(
        'Услуга оформлена',
        fields: {
          'entity': 'service_purchases',
          'entity_id': purchaseId,
          'client_id': clientId,
          'service_id': serviceId,
          'actor_id': audit.actorId,
          'request_id': audit.requestId,
        },
      );

      return purchase;
    });
  }

  /// Активирует отложенную покупку: срок и периоды квоты создаются здесь.
  Future<ServicePurchase> activate(
    String id, {
    required AuditContext audit,
  }) {
    return _database.runTx((session) async {
      final row = await _purchaseRepository.getRowById(id, session: session);
      if (row == null) {
        throw const NotFoundException('Покупка не найдена');
      }

      final status = row['status'] as int;
      if (status != ServicePurchaseStatus.draft) {
        throw const ConflictException('Покупка уже активирована или отменена');
      }

      final now = DateTime.now();
      final durationDays = row['duration_days'] as int?;
      final expiry = durationDays == null
          ? null
          : now.add(Duration(days: durationDays));

      await _purchaseRepository.activate(
        id: id,
        activationDate: now,
        expiryDate: expiry,
        actualExpiryDate: expiry,
        updatedBy: audit.actorId ?? '',
        session: session,
      );

      final quotaLimit = row['quota_limit'] as int?;
      if (row['usage_limit_mode'] == ServiceUsageLimitMode.quota &&
          quotaLimit != null) {
        await _createQuotaPeriods(
          purchaseId: id,
          activation: now,
          expiry: expiry,
          quotaPeriod: row['quota_period'] as int?,
          quotaLimit: quotaLimit,
          session: session,
        );
      }

      final purchase = await _purchaseRepository.getById(id, session: session);
      if (purchase == null) {
        throw const NotFoundException('Покупка не найдена после активации');
      }

      await _auditService.record(
        session: session,
        tableName: 'service_purchases',
        rowPk: id,
        action: 'UPDATE',
        context: audit,
        oldValues: {'status': status},
        newValues: purchase.toJson(),
      );

      appLog.info(
        'Услуга активирована',
        fields: {
          'entity': 'service_purchases',
          'entity_id': id,
          'actor_id': audit.actorId,
          'request_id': audit.requestId,
        },
      );

      return purchase;
    });
  }

  /// Покупка по id — нужна контроллеру для проверки доступа.
  Future<ServicePurchase?> getById(String id) {
    return _purchaseRepository.getById(id);
  }

  /// Активные и истёкшие покупки клиента.
  Future<List<ServicePurchase>> getClientServices(String clientId) {
    return _purchaseRepository.getClientServices(clientId);
  }

  /// История покупок с фильтрами.
  Future<List<ServicePurchase>> getHistory({
    String? clientId,
    int? status,
  }) {
    return _purchaseRepository.getHistory(clientId: clientId, status: status);
  }

  /// Цена покупки: базовая цена минус скидка суммой и процентами.
  double? _finalPrice({
    required double? basePrice,
    required double discountAmount,
    required double discountPercent,
  }) {
    if (basePrice == null) {
      return null;
    }
    final percentPart = basePrice * discountPercent / 100;
    final result = basePrice - discountAmount - percentPart;
    return result < 0 ? 0 : result;
  }

  /// Создаёт все календарные периоды квоты на срок услуги.
  Future<void> _createQuotaPeriods({
    required String purchaseId,
    required DateTime activation,
    required DateTime? expiry,
    required int? quotaPeriod,
    required int quotaLimit,
    required Session session,
  }) async {
    final periods = const QuotaPeriodCalculator().build(
      activation: activation,
      expiry: expiry,
      quotaPeriod: quotaPeriod,
      quotaLimit: quotaLimit,
    );
    for (final period in periods) {
      await _purchaseRepository.createQuotaPeriod(
        purchaseId: purchaseId,
        periodStart: period.start,
        periodEnd: period.end,
        quotaLimit: quotaLimit,
        session: session,
      );
    }
  }
}
