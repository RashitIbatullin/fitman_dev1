import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/errors/app_exception.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/modules/appointments/repositories/appointment_repository.dart';
import 'package:fitman_backend/security/access_policy.dart';
import 'package:fitman_common/modules/services/appointment.model.dart';

/// Бизнес-логика записей на услуги.
///
/// Завершение записи создаёт посещение и списание; пропуск по вине центра
/// сеанс не списывает.
class AppointmentService {
  AppointmentService(this._repository, this._database);

  final AppointmentRepository _repository;
  final Database _database;
  final AuditService _auditService = const AuditService();

  Future<List<Appointment>> getAll({
    DateTime? from,
    DateTime? to,
    String? executorId,
    int? status,
  }) {
    return _repository.getAll(
      from: from,
      to: to,
      executorId: executorId,
      status: status,
    );
  }

  /// Отмечает запись выполненной: посещение + списание услуги.
  Future<void> complete(String id, {required AuditContext audit}) {
    return _database.runTx((session) async {
      final row = await _repository.getRowById(id, session: session);
      if (row == null) {
        throw const NotFoundException('Запись не найдена');
      }
      _ensureScheduled(row);
      _ensureCanAct(row, audit);

      final status = row['status'] as int;
      if (status != AppointmentStatus.scheduled) {
        throw const ConflictException('Запись уже обработана');
      }

      await _repository.updateStatus(
        id: id,
        status: AppointmentStatus.completed,
        updatedBy: audit.actorId ?? '',
        session: session,
      );

      final purchaseId = row['purchase_id']?.toString();
      final visitId = await _repository.createVisit(
        clientId: row['client_id'].toString(),
        serviceName: (row['service_name'] ?? '') as String,
        serviceDescription: row['service_description'] as String?,
        appointmentId: id,
        purchaseId: purchaseId,
        createdBy: audit.actorId ?? '',
        session: session,
      );
      await _repository.setVisitId(id: id, visitId: visitId, session: session);

      if (purchaseId != null) {
        await _repository.createUsage(
          purchaseId: purchaseId,
          clientId: row['client_id'].toString(),
          consumedBy: audit.actorId ?? '',
          session: session,
        );
      }

      await _auditService.record(
        session: session,
        tableName: 'appointments',
        rowPk: id,
        action: 'UPDATE',
        context: audit,
        oldValues: {'status': status},
        newValues: {
          'status': AppointmentStatus.completed,
          'visit_id': visitId,
        },
      );

      appLog.info(
        'Запись выполнена',
        fields: {
          'entity': 'appointments',
          'entity_id': id,
          'visit_id': visitId,
          'actor_id': audit.actorId,
          'request_id': audit.requestId,
        },
      );
    });
  }

  /// Отмечает пропуск. Списание зависит от стороны пропуска.
  Future<void> skip(
    String id, {
    required int party,
    required int reasonCode,
    String? note,
    required AuditContext audit,
  }) {
    if (!const {1, 2, 3}.contains(party)) {
      throw const ValidationException('Неизвестная сторона пропуска');
    }
    if (reasonCode <= 0) {
      throw const ValidationException('Укажите причину пропуска');
    }

    return _database.runTx((session) async {
      final row = await _repository.getRowById(id, session: session);
      if (row == null) {
        throw const NotFoundException('Запись не найдена');
      }
      _ensureScheduled(row);
      _ensureCanAct(row, audit);

      final status = row['status'] as int;
      if (status != AppointmentStatus.scheduled) {
        throw const ConflictException('Запись уже обработана');
      }

      await _repository.updateStatus(
        id: id,
        status: AppointmentStatus.skipped,
        skipParty: party,
        skipReason: reasonCode,
        note: note,
        updatedBy: audit.actorId ?? '',
        session: session,
      );

      // По вине клиента сеанс списывается, если услуга это разрешает.
      final noShowPolicy = (row['no_show_policy'] as int?) ?? 0;
      final purchaseId = row['purchase_id']?.toString();
      final chargeClient = party == AppointmentSkipParty.client &&
          noShowPolicy == 0 &&
          purchaseId != null;

      if (chargeClient) {
        await _repository.createUsage(
          purchaseId: purchaseId,
          clientId: row['client_id'].toString(),
          consumedBy: audit.actorId ?? '',
          session: session,
        );
      }

      await _auditService.record(
        session: session,
        tableName: 'appointments',
        rowPk: id,
        action: 'UPDATE',
        context: audit,
        oldValues: {'status': status},
        newValues: {
          'status': AppointmentStatus.skipped,
          'skip_party': party,
          'skip_reason': reasonCode,
          'charged': chargeClient,
        },
      );
    });
  }

  void _ensureScheduled(Map<String, dynamic> row) {
    final executorId = row['executor_id']?.toString();
    if (executorId == null) {
      throw const ValidationException('У записи не назначен исполнитель');
    }
  }

  /// Исполнитель работает только со своими записями; менеджер и админ — с любыми.
  void _ensureCanAct(Map<String, dynamic> row, AuditContext audit) {
    if (AccessPolicy.hasAnyRoleCsv(audit.actorRole, RoleGroups.manager)) {
      return;
    }

    final executorId = row['executor_id']?.toString();
    if (executorId == null || executorId != audit.actorId) {
      throw const ForbiddenException('Запись назначена другому исполнителю');
    }
  }
}

