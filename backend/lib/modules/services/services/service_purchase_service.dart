import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/modules/services/repositories/service_purchase_repository.dart';
import 'package:fitman_backend/modules/services/repositories/service_repository.dart';
import 'package:fitman_common/fitman_common.dart';

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
      if (!service.isActive) {
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

      final now = DateTime.now().toUtc();
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

      // Первый период квоты открывается при оформлении, если активация
      // немедленная. При отложенной активации период создаст активация.
      if (immediate &&
          service.usageLimitMode == ServiceUsageLimitMode.quota &&
          service.quotaLimit != null) {
        final periodEnd = _periodEnd(now, service.quotaPeriod);
        await _purchaseRepository.createQuotaPeriod(
          purchaseId: purchaseId,
          periodStart: now,
          periodEnd: periodEnd,
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

  /// Конец первого периода квоты.
  DateTime _periodEnd(DateTime start, int? quotaPeriod) {
    switch (quotaPeriod) {
      case ServiceQuotaPeriod.day:
        return start.add(const Duration(days: 1));
      case ServiceQuotaPeriod.week:
        return start.add(const Duration(days: 7));
      case ServiceQuotaPeriod.month:
        return _addMonth(start);
      default:
        return _addMonth(start);
    }
  }

  DateTime _addMonth(DateTime value) {
    final nextMonth = value.month + 1;
    final year = value.year + (nextMonth - 1) ~/ 12;
    final month = (nextMonth - 1) % 12 + 1;
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    final day = value.day > lastDay ? lastDay : value.day;
    return DateTime.utc(
      year,
      month,
      day,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }
}
