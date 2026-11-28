import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/modules/services/repositories/service_repository.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

/// Каталог услуг: чтение и управление позициями.
class ServiceCatalogService {
  ServiceCatalogService(this._repository, this._database);

  final ServiceRepository _repository;
  final Database _database;
  final AuditService _auditService = const AuditService();

  Future<List<Service>> getAll({
    String? type,
    bool? active,
    bool? archived,
  }) {
    return _repository.getAll(type: type, active: active, archived: archived);
  }

  Future<List<Map<String, dynamic>>> getTypes() {
    return _repository.getTypes();
  }

  Future<List<Map<String, dynamic>>> getSpecializations() {
    return _repository.getSpecializations();
  }

  Future<Service?> getById(String id) {
    return _repository.getById(id);
  }

  /// Создаёт позицию каталога и пишет аудит в той же транзакции.
  Future<Service> create(ServiceDraft draft, {required AuditContext audit}) {
    return _database.runTx((session) async {
      final normalized = await _validateAndNormalize(draft, session: session);
      final created = await _repository.create(
        normalized,
        createdBy: audit.actorId ?? '',
        session: session,
      );

      await _auditService.record(
        session: session,
        tableName: 'services',
        rowPk: created.id,
        action: 'INSERT',
        context: audit,
        newValues: created.toJson(),
      );

      appLog.info(
        'Услуга создана',
        fields: {
          'entity': 'services',
          'entity_id': created.id,
          'actor_id': audit.actorId,
          'request_id': audit.requestId,
        },
      );
      return created;
    });
  }

  /// Изменяет позицию каталога; уже оформленные покупки не затрагиваются.
  Future<Service> update(
    String id,
    ServiceDraft draft, {
    required AuditContext audit,
  }) {
    return _database.runTx((session) async {
      final old = await _repository.getById(id, session: session);
      if (old == null) {
        throw const NotFoundException('Услуга не найдена');
      }

      final normalized = await _validateAndNormalize(
        draft,
        session: session,
        excludeId: id,
      );
      final updated = await _repository.update(
        id,
        normalized,
        updatedBy: audit.actorId ?? '',
        session: session,
      );

      await _auditService.record(
        session: session,
        tableName: 'services',
        rowPk: id,
        action: 'UPDATE',
        context: audit,
        oldValues: old.toJson(),
        newValues: updated.toJson(),
      );

      appLog.info(
        'Услуга изменена',
        fields: {
          'entity': 'services',
          'entity_id': id,
          'actor_id': audit.actorId,
          'request_id': audit.requestId,
        },
      );
      return updated;
    });
  }

  Future<Service> archive(
    String id, {
    required String reason,
    required AuditContext audit,
  }) {
    if (reason.trim().length < 5) {
      throw const ValidationException('Причина архивации — не менее 5 символов');
    }

    return _database.runTx((session) async {
      final old = await _repository.getById(id, session: session);
      if (old == null) {
        throw const NotFoundException('Услуга не найдена');
      }
      if (old.archivedAt != null) {
        throw const ConflictException('Услуга уже в архиве');
      }

      await _repository.archive(
        id: id,
        reason: reason.trim(),
        archivedBy: audit.actorId ?? '',
        session: session,
      );
      final updated = await _repository.getById(id, session: session);
      if (updated == null) {
        throw const NotFoundException('Услуга не найдена после архивации');
      }

      await _auditService.record(
        session: session,
        tableName: 'services',
        rowPk: id,
        action: 'ARCHIVE',
        context: audit,
        oldValues: old.toJson(),
        newValues: updated.toJson(),
        reason: reason.trim(),
      );
      return updated;
    });
  }

  Future<Service> unarchive(
    String id, {
    required AuditContext audit,
  }) {
    return _database.runTx((session) async {
      final old = await _repository.getById(id, session: session);
      if (old == null) {
        throw const NotFoundException('Услуга не найдена');
      }
      if (old.archivedAt == null) {
        throw const ConflictException('Услуга не находится в архиве');
      }

      await _repository.unarchive(
        id: id,
        updatedBy: audit.actorId ?? '',
        session: session,
      );
      final updated = await _repository.getById(id, session: session);
      if (updated == null) {
        throw const NotFoundException('Услуга не найдена после восстановления');
      }

      await _auditService.record(
        session: session,
        tableName: 'services',
        rowPk: id,
        action: 'RESTORE',
        context: audit,
        oldValues: old.toJson(),
        newValues: updated.toJson(),
      );
      return updated;
    });
  }

  /// Проверяет ограничения карточки и очищает лишние поля режима лимита.
  Future<ServiceDraft> _validateAndNormalize(
    ServiceDraft draft, {
    required Session session,
    String? excludeId,
  }) async {
    final code = draft.code.trim();
    final name = draft.name.trim();
    if (code.isEmpty) {
      throw const ValidationException('Укажите код услуги');
    }
    if (name.isEmpty) {
      throw const ValidationException('Укажите название услуги');
    }
    if (!await _repository.serviceTypeExists(
      draft.serviceTypeId,
      session: session,
    )) {
      throw const ValidationException('Тип услуги не найден');
    }
    if (draft.executorSpecializationId != null &&
        !await _repository.specializationExists(
          draft.executorSpecializationId!,
          session: session,
        )) {
      throw const ValidationException('Специализация не найдена');
    }
    if (await _repository.codeExists(
      code,
      excludeId: excludeId,
      session: session,
    )) {
      throw const ConflictException('Услуга с таким кодом уже существует');
    }
    if (draft.basePrice != null && draft.basePrice! < 0) {
      throw const ValidationException('Цена не может быть отрицательной');
    }
    if (draft.durationDays != null && draft.durationDays! <= 0) {
      throw const ValidationException('Срок действия должен быть больше нуля');
    }
    if (draft.durationMinutes != null && draft.durationMinutes! <= 0) {
      throw const ValidationException('Длительность должна быть больше нуля');
    }
    if (!const {
      ServiceUsageLimitMode.unlimited,
      ServiceUsageLimitMode.total,
      ServiceUsageLimitMode.quota,
    }.contains(draft.usageLimitMode)) {
      throw const ValidationException('Неизвестный режим ограничения');
    }

    int? maxUses;
    int? quotaPeriod;
    int? quotaLimit;
    switch (draft.usageLimitMode) {
      case ServiceUsageLimitMode.unlimited:
        break;
      case ServiceUsageLimitMode.total:
        if (draft.maxUses == null || draft.maxUses! <= 0) {
          throw const ValidationException(
            'Для общего лимита укажите количество использований',
          );
        }
        maxUses = draft.maxUses;
        break;
      case ServiceUsageLimitMode.quota:
        if (draft.quotaLimit == null || draft.quotaLimit! <= 0) {
          throw const ValidationException('Укажите лимит квоты на период');
        }
        if (!const {
          ServiceQuotaPeriod.day,
          ServiceQuotaPeriod.week,
          ServiceQuotaPeriod.month,
        }.contains(draft.quotaPeriod)) {
          throw const ValidationException('Выберите период квоты');
        }
        maxUses = draft.maxUses;
        quotaPeriod = draft.quotaPeriod;
        quotaLimit = draft.quotaLimit;
        break;
    }

    return ServiceDraft(
      code: code,
      name: name,
      description: draft.description?.trim(),
      serviceTypeId: draft.serviceTypeId,
      basePrice: draft.basePrice,
      currency: draft.currency,
      durationDays: draft.durationDays,
      usageLimitMode: draft.usageLimitMode,
      maxUses: maxUses,
      quotaPeriod: quotaPeriod,
      quotaLimit: quotaLimit,
      durationMinutes: draft.durationMinutes,
      executorSpecializationId: draft.executorSpecializationId,
      activationRequired: draft.activationRequired,
      allowStacking: draft.allowStacking,
      grantsAccess: draft.grantsAccess,
      isActive: draft.isActive,
    );
  }
}
