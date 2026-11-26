import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

/// Запросы каталога услуг.
abstract class ServiceRepository {
  /// Услуги каталога с типом, ценой и ограничениями.
  Future<List<Service>> getAll({String? type, bool? active});

  /// Справочник типов услуг.
  Future<List<Map<String, dynamic>>> getTypes();

  /// Карточка услуги — нужна при оформлении покупки.
  Future<Service?> getById(String id, {Session? session});
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
      s.activation_required,
      s.allow_stacking,
      s.grants_access,
      s.is_active
    FROM services s
    JOIN service_types st ON st.id = s.service_type_id
  ''';

  @override
  Future<List<Service>> getAll({String? type, bool? active}) async {
    final connection = await _db.connection;
    final where = <String>['s.archived_at IS NULL'];
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
      activationRequired: map['activation_required'] as bool,
      allowStacking: map['allow_stacking'] as bool,
      grantsAccess: map['grants_access'] as bool,
      isActive: map['is_active'] as bool,
    );
  }
}
