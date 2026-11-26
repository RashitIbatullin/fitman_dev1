import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_common/modules/services/appointment.model.dart';
import 'package:postgres/postgres.dart';

/// Запросы по записям на услуги.
///
/// Сетки слотов и проверки занятости здесь нет: запись — это факт
/// «клиент записан на дату и время к исполнителю».
abstract class AppointmentRepository {
  Future<List<Appointment>> getAll({
    DateTime? from,
    DateTime? to,
    String? executorId,
    int? status,
  });

  /// Строка записи вместе со служебными полями услуги (нужны в транзакции).
  Future<Map<String, dynamic>?> getRowById(String id, {Session? session});

  Future<void> updateStatus({
    required String id,
    required int status,
    int? skipParty,
    int? skipReason,
    String? note,
    required String updatedBy,
    Session? session,
  });

  Future<void> setVisitId({
    required String id,
    required String visitId,
    Session? session,
  });

  Future<String> createVisit({
    required String clientId,
    required String serviceName,
    String? serviceDescription,
    required String appointmentId,
    String? purchaseId,
    required String createdBy,
    Session? session,
  });

  Future<String> createUsage({
    required String purchaseId,
    required String clientId,
    required String consumedBy,
    Session? session,
  });
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._db);

  final Database _db;

  static const String _selectBase = '''
    SELECT
      a.id,
      a.client_id,
      concat_ws(' ', cu.last_name, cu.first_name) AS client_name,
      a.service_id,
      s.name AS service_name,
      coalesce(a.service_description, s.description) AS service_description,
      a.executor_id,
      concat_ws(' ', eu.last_name, eu.first_name) AS executor_name,
      a.start_at,
      a.duration_minutes,
      a.status,
      a.note,
      a.skip_party,
      a.skip_reason,
      a.purchase_id,
      s.name AS service_name_raw,
      s.no_show_policy
    FROM appointments a
    JOIN users cu ON cu.id = a.client_id
    JOIN services s ON s.id = a.service_id
    LEFT JOIN users eu ON eu.id = a.executor_id
  ''';

  @override
  Future<List<Appointment>> getAll({
    DateTime? from,
    DateTime? to,
    String? executorId,
    int? status,
  }) async {
    final connection = await _db.connection;
    final where = <String>[];
    final parameters = <String, dynamic>{};

    if (from != null) {
      where.add('a.start_at >= @from');
      parameters['from'] = from;
    }
    if (to != null) {
      where.add('a.start_at < @to');
      parameters['to'] = to;
    }
    if (executorId != null) {
      where.add('a.executor_id = @executorId');
      parameters['executorId'] = executorId;
    }
    if (status != null) {
      where.add('a.status = @status');
      parameters['status'] = status;
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final rows = await connection.execute(
      Sql.named('$_selectBase $whereClause ORDER BY a.start_at'),
      parameters: parameters,
    );

    return rows.map(_toAppointment).toList();
  }

  @override
  Future<Map<String, dynamic>?> getRowById(
    String id, {
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('$_selectBase WHERE a.id = @id FOR UPDATE OF a'),
      parameters: {'id': id},
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first.toColumnMap();
  }

  @override
  Future<void> updateStatus({
    required String id,
    required int status,
    int? skipParty,
    int? skipReason,
    String? note,
    required String updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE appointments
           SET status = @status,
               skip_party = COALESCE(@skipParty, skip_party),
               skip_reason = COALESCE(@skipReason, skip_reason),
               note = COALESCE(@note, note),
               updated_at = NOW(),
               updated_by = @updatedBy
         WHERE id = @id
      '''),
      parameters: {
        'id': id,
        'status': status,
        'skipParty': skipParty,
        'skipReason': skipReason,
        'note': note,
        'updatedBy': updatedBy,
      },
    );
  }

  @override
  Future<void> setVisitId({
    required String id,
    required String visitId,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('UPDATE appointments SET visit_id = @visitId WHERE id = @id'),
      parameters: {'id': id, 'visitId': visitId},
    );
  }

  @override
  Future<String> createVisit({    required String clientId,
    required String serviceName,
    String? serviceDescription,
    required String appointmentId,
    String? purchaseId,
    required String createdBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO visits (
          client_id, started_at, service_name, service_description,
          appointment_id, purchase_id, source, created_by
        ) VALUES (
          @clientId, NOW(), @serviceName, @serviceDescription,
          @appointmentId, @purchaseId, 1, @createdBy
        )
        RETURNING id
      '''),
      parameters: {
        'clientId': clientId,
        'serviceName': serviceName,
        'serviceDescription': serviceDescription,
        'appointmentId': appointmentId,
        'purchaseId': purchaseId,
        'createdBy': createdBy,
      },
    );
    return result.first[0].toString();
  }

  @override
  Future<String> createUsage({
    required String purchaseId,
    required String clientId,
    required String consumedBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final result = await conn.execute(
      Sql.named('''
        INSERT INTO service_usages (
          purchase_id, client_id, status, consumed_at, consumed_by, created_by
        ) VALUES (
          @purchaseId, @clientId, 1, NOW(), @consumedBy, @consumedBy
        )
        RETURNING id
      '''),
      parameters: {
        'purchaseId': purchaseId,
        'clientId': clientId,
        'consumedBy': consumedBy,
      },
    );
    return result.first[0].toString();
  }

  Appointment _toAppointment(ResultRow row) {
    final map = row.toColumnMap();
    return Appointment(
      id: map['id'].toString(),
      clientId: map['client_id'].toString(),
      clientName: map['client_name'] as String?,
      serviceId: map['service_id'].toString(),
      serviceName: (map['service_name'] ?? '') as String,
      serviceDescription: map['service_description'] as String?,
      executorId: map['executor_id']?.toString(),
      executorName: map['executor_name'] as String?,
      startAt: map['start_at'] as DateTime,
      durationMinutes: map['duration_minutes'] as int?,
      status: map['status'] as int,
      note: map['note'] as String?,
      skipParty: map['skip_party'] as int?,
      skipReason: map['skip_reason'] as int?,
      purchaseId: map['purchase_id']?.toString(),
    );
  }
}
