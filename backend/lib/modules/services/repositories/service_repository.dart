import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

/// Данные для создания и изменения позиции каталога услуг.
class ServiceDraft {
  const ServiceDraft({
    required this.code,
    required this.name,
    this.description,
    required this.serviceTypeId,
    this.basePrice,
    this.currency = 'RUB',
    this.durationDays,
    this.usageLimitMode = ServiceUsageLimitMode.total,
    this.maxUses,
    this.quotaPeriod,
    this.quotaLimit,
    this.durationMinutes,
    this.executorSpecializationId,
    this.activationRequired = false,
    this.allowStacking = true,
    this.grantsAccess = true,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String? description;
  final String serviceTypeId;
  final double? basePrice;
  final String currency;
  final int? durationDays;
  final int usageLimitMode;
  final int? maxUses;
  final int? quotaPeriod;
  final int? quotaLimit;
  final int? durationMinutes;
  final String? executorSpecializationId;
  final bool activationRequired;
  final bool allowStacking;
  final bool grantsAccess;
  final bool isActive;
}

/// Запросы каталога услуг.
abstract class ServiceRepository {
  /// Услуги каталога с типом, ценой и ограничениями.
  Future<List<Service>> getAll({
    String? type,
    bool? active,
    bool? archived,
  });

  /// Справочник типов услуг.
  Future<List<Map<String, dynamic>>> getTypes();

  /// Справочник специализаций исполнителей.
  Future<List<Map<String, dynamic>>> getSpecializations();

  /// Карточка услуги — нужна при оформлении покупки.
  Future<Service?> getById(String id, {Session? session});

  Future<bool> serviceTypeExists(String id, {Session? session});

  Future<bool> specializationExists(String id, {Session? session});

  Future<bool> codeExists(String code, {String? excludeId, Session? session});

  Future<Service> create(
    ServiceDraft draft, {
    required String createdBy,
    Session? session,
  });

  Future<Service> update(
    String id,
    ServiceDraft draft, {
    required String updatedBy,
    Session? session,
  });

  Future<void> archive({
    required String id,
    required String reason,
    required String archivedBy,
    Session? session,
  });

  Future<void> unarchive({
    required String id,
    required String updatedBy,
    Session? session,
  });
}

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl(this._db);

  final Database _db;

  static const String _selectBase = '''
    SELECT
      s.id,
      s.code,
      s.name,
      s.description,
      s.service_type_id,
      st.code AS service_type_code,
      st.title AS service_type_title,
      s.base_price::float8 AS base_price,
      s.currency,
      s.duration_days,
      s.usage_limit_mode,
      s.max_uses,
      s.quota_period,
      s.quota_limit,
      s.duration_minutes,
      s.executor_specialization_id,
      sp.code AS executor_specialization_code,
      sp.title AS executor_specialization_title,
      s.activation_required,
      s.allow_stacking,
      s.grants_access,
      s.is_active,
      s.archived_at,
      s.archived_reason,
      s.created_at,
      s.updated_at
    FROM services s
    JOIN service_types st ON st.id = s.service_type_id
    LEFT JOIN specializations sp ON sp.id = s.executor_specialization_id
  ''';

  @override
  Future<List<Service>> getAll({
    String? type,
    bool? active,
    bool? archived,
  }) async {
    final connection = await _db.connection;
    final where = <String>[
      archived == true ? 's.archived_at IS NOT NULL' : 's.archived_at IS NULL',
    ];
    final parameters = <String, dynamic>{};

    if (type != null && type.isNotEmpty) {
      where.add('(st.code = @type OR s.service_type_id::text = @type)');
      parameters['type'] = type;
    }
    if (active != null) {
      where.add('s.is_active = @active');
      parameters['active'] = active;
    }

    final rows = await connection.execute(
      Sql.named('$_selectBase WHERE ${where.join(' AND ')} ORDER BY s.name'),
      parameters: parameters,
    );
    return rows.map(_toService).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTypes() async {
    final connection = await _db.connection;
    final rows = await connection.execute(
      Sql.named('''
        SELECT id, code, title
          FROM service_types
         WHERE is_active = true AND archived_at IS NULL
         ORDER BY title
      '''),
    );
    return rows
        .map(
          (row) => <String, dynamic>{
            'id': row[0].toString(),
            'code': row[1].toString(),
            'title': row[2].toString(),
          },
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSpecializations() async {
    final connection = await _db.connection;
    final rows = await connection.execute(
      Sql.named('''
        SELECT id, code, title, is_medical
          FROM specializations
         WHERE is_active = true AND archived_at IS NULL
         ORDER BY title
      '''),
    );
    return rows
        .map(
          (row) => <String, dynamic>{
            'id': row[0].toString(),
            'code': row[1].toString(),
            'title': row[2].toString(),
            'isMedical': row[3] as bool,
          },
        )
        .toList();
  }

  @override
  Future<Service?> getById(String id, {Session? session}) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('$_selectBase WHERE s.id = @id'),
      parameters: {'id': id},
    );
    if (rows.isEmpty) {
      return null;
    }
    return _toService(rows.first);
  }

  @override
  Future<bool> serviceTypeExists(String id, {Session? session}) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('SELECT 1 FROM service_types WHERE id = @id'),
      parameters: {'id': id},
    );
    return rows.isNotEmpty;
  }

  @override
  Future<bool> specializationExists(String id, {Session? session}) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('SELECT 1 FROM specializations WHERE id = @id'),
      parameters: {'id': id},
    );
    return rows.isNotEmpty;
  }

  @override
  Future<bool> codeExists(
    String code, {
    String? excludeId,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = excludeId == null
        ? await conn.execute(
            Sql.named('SELECT 1 FROM services WHERE code = @code LIMIT 1'),
            parameters: {'code': code},
          )
        : await conn.execute(
            Sql.named('''
              SELECT 1
                FROM services
               WHERE code = @code AND id <> @excludeId
               LIMIT 1
            '''),
            parameters: {'code': code, 'excludeId': excludeId},
          );
    return rows.isNotEmpty;
  }

  @override
  Future<Service> create(
    ServiceDraft draft, {
    required String createdBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('''
        INSERT INTO services (
          code, name, description, service_type_id, base_price, currency,
          duration_days, usage_limit_mode, max_uses,
          quota_period, quota_limit, duration_minutes,
          executor_specialization_id, activation_required,
          allow_stacking, grants_access, is_active,
          created_by, updated_by
        ) VALUES (
          @code, @name, @description, @serviceTypeId, @basePrice, @currency,
          @durationDays, @usageLimitMode, @maxUses,
          @quotaPeriod, @quotaLimit, @durationMinutes,
          @specializationId, @activationRequired,
          @allowStacking, @grantsAccess, @isActive,
          @createdBy, @createdBy
        )
        RETURNING id
      '''),
      parameters: {
        'code': draft.code,
        'name': draft.name,
        'description': draft.description,
        'serviceTypeId': draft.serviceTypeId,
        'basePrice': draft.basePrice,
        'currency': draft.currency,
        'durationDays': draft.durationDays,
        'usageLimitMode': draft.usageLimitMode,
        'maxUses': draft.maxUses,
        'quotaPeriod': draft.quotaPeriod,
        'quotaLimit': draft.quotaLimit,
        'durationMinutes': draft.durationMinutes,
        'specializationId': draft.executorSpecializationId,
        'activationRequired': draft.activationRequired,
        'allowStacking': draft.allowStacking,
        'grantsAccess': draft.grantsAccess,
        'isActive': draft.isActive,
        'createdBy': createdBy,
      },
    );
    final id = rows.first[0].toString();
    final created = await getById(id, session: session);
    if (created == null) {
      throw StateError('Услуга не найдена после создания');
    }
    return created;
  }

  @override
  Future<Service> update(
    String id,
    ServiceDraft draft, {
    required String updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE services
           SET code = @code,
               name = @name,
               description = @description,
               service_type_id = @serviceTypeId,
               base_price = @basePrice,
               currency = @currency,
               duration_days = @durationDays,
               usage_limit_mode = @usageLimitMode,
               max_uses = @maxUses,
               quota_period = @quotaPeriod,
               quota_limit = @quotaLimit,
               duration_minutes = @durationMinutes,
               executor_specialization_id = @specializationId,
               activation_required = @activationRequired,
               allow_stacking = @allowStacking,
               grants_access = @grantsAccess,
               is_active = @isActive,
               updated_at = NOW(),
               updated_by = @updatedBy
         WHERE id = @id
      '''),
      parameters: {
        'id': id,
        'code': draft.code,
        'name': draft.name,
        'description': draft.description,
        'serviceTypeId': draft.serviceTypeId,
        'basePrice': draft.basePrice,
        'currency': draft.currency,
        'durationDays': draft.durationDays,
        'usageLimitMode': draft.usageLimitMode,
        'maxUses': draft.maxUses,
        'quotaPeriod': draft.quotaPeriod,
        'quotaLimit': draft.quotaLimit,
        'durationMinutes': draft.durationMinutes,
        'specializationId': draft.executorSpecializationId,
        'activationRequired': draft.activationRequired,
        'allowStacking': draft.allowStacking,
        'grantsAccess': draft.grantsAccess,
        'isActive': draft.isActive,
        'updatedBy': updatedBy,
      },
    );
    final updated = await getById(id, session: session);
    if (updated == null) {
      throw StateError('Услуга не найдена после изменения');
    }
    return updated;
  }

  @override
  Future<void> archive({
    required String id,
    required String reason,
    required String archivedBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE services
           SET archived_at = NOW(),
               archived_by = @archivedBy,
               archived_reason = @reason,
               updated_at = NOW(),
               updated_by = @archivedBy
         WHERE id = @id
      '''),
      parameters: {'id': id, 'reason': reason, 'archivedBy': archivedBy},
    );
  }

  @override
  Future<void> unarchive({
    required String id,
    required String updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE services
           SET archived_at = NULL,
               archived_by = NULL,
               archived_reason = NULL,
               updated_at = NOW(),
               updated_by = @updatedBy
         WHERE id = @id
      '''),
      parameters: {'id': id, 'updatedBy': updatedBy},
    );
  }

  Service _toService(ResultRow row) {
    final map = row.toColumnMap();
    return Service(
      id: map['id'].toString(),
      code: map['code'].toString(),
      name: map['name'].toString(),
      description: map['description'] as String?,
      serviceTypeId: map['service_type_id'].toString(),
      serviceTypeCode: map['service_type_code'].toString(),
      serviceTypeTitle: map['service_type_title'].toString(),
      basePrice: (map['base_price'] as num?)?.toDouble(),
      currency: map['currency'].toString(),
      durationDays: map['duration_days'] as int?,
      usageLimitMode: map['usage_limit_mode'] as int,
      maxUses: map['max_uses'] as int?,
      quotaPeriod: map['quota_period'] as int?,
      quotaLimit: map['quota_limit'] as int?,
      durationMinutes: map['duration_minutes'] as int?,
      executorSpecializationId:
          map['executor_specialization_id']?.toString(),
      executorSpecializationCode:
          map['executor_specialization_code']?.toString(),
      executorSpecializationTitle:
          map['executor_specialization_title']?.toString(),
      activationRequired: map['activation_required'] as bool,
      allowStacking: map['allow_stacking'] as bool,
      grantsAccess: map['grants_access'] as bool,
      isActive: map['is_active'] as bool,
      archivedAt: map['archived_at'] as DateTime?,
      archivedReason: map['archived_reason'] as String?,
      createdAt: map['created_at'] as DateTime?,
      updatedAt: map['updated_at'] as DateTime?,
    );
  }
}
