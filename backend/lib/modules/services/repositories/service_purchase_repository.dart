import 'package:fitman_backend/config/database.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:postgres/postgres.dart';

/// Запросы оформленных услуг: создание, остатки, история.
abstract class ServicePurchaseRepository {
  /// Строка клиента (проверка существования при оформлении).
  Future<Map<String, dynamic>?> getClientRow(
    String clientId, {
    Session? session,
  });

  /// Есть ли у клиента действующая покупка этой услуги.
  Future<bool> hasActivePurchase({
    required String clientId,
    required String serviceId,
    Session? session,
  });

  /// Создаёт покупку и возвращает её идентификатор.
  Future<String> createPurchase({
    required String clientId,
    required String serviceId,
    required String soldBy,
    required double? purchasePrice,
    required double discountPercent,
    required double discountAmount,
    required double? finalPrice,
    required int paymentStatus,
    required int? paymentSource,
    required DateTime purchaseDate,
    required DateTime? activationDate,
    required DateTime? expiryDate,
    required DateTime? actualExpiryDate,
    required int? totalUses,
    required int status,
    Session? session,
  });

  Future<void> addParticipant({
    required String purchaseId,
    required String clientId,
    required String createdBy,
    Session? session,
  });

  Future<void> createQuotaPeriod({
    required String purchaseId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int quotaLimit,
    Session? session,
  });

  /// Активные и истёкшие покупки клиента с остатком и текущей квотой.
  Future<List<ServicePurchase>> getClientServices(String clientId);

  /// История покупок с фильтрами.
  Future<List<ServicePurchase>> getHistory({
    String? clientId,
    int? status,
  });

  /// Покупка по id — для ответа API после создания.
  Future<ServicePurchase?> getById(String id, {Session? session});

  /// Сырая строка покупки вместе с параметрами услуги, нужными активации.
  Future<Map<String, dynamic>?> getRowById(String id, {Session? session});

  /// Переводит покупку в активную и фиксирует срок.
  Future<void> activate({
    required String id,
    required DateTime activationDate,
    required DateTime? expiryDate,
    required DateTime? actualExpiryDate,
    required String updatedBy,
    Session? session,
  });

  /// Покупки, у которых истёк срок или закончились использования.
  Future<List<Map<String, dynamic>>> getDueForStatusUpdate({Session? session});

  Future<void> updateStatus({
    required String id,
    required int status,
    Session? session,
  });
}

class ServicePurchaseRepositoryImpl implements ServicePurchaseRepository {
  ServicePurchaseRepositoryImpl(this._db);

  final Database _db;

  /// Эффективный статус: истёкшая или исчерпанная покупка показывается
  /// таковой, даже если плановая задача ещё не обновила хранимый статус.
  static const String _selectBase = '''
    SELECT
      p.id,
      p.client_id,
      concat_ws(' ', cu.last_name, cu.first_name) AS client_name,
      p.service_id,
      s.name AS service_name,
      s.code AS service_code,
      st.code AS service_type_code,
      st.title AS service_type_title,
      p.purchase_price::float8 AS purchase_price,
      p.discount_percent::float8 AS discount_percent,
      p.discount_amount::float8 AS discount_amount,
      p.final_price::float8 AS final_price,
      p.payment_status,
      p.payment_source,
      p.purchase_date,
      p.activation_date,
      p.expiry_date,
      p.actual_expiry_date,
      p.total_uses,
      p.used_uses,
      CASE
        WHEN p.total_uses IS NULL THEN NULL
        ELSE p.total_uses - p.used_uses
      END AS remaining_uses,
      CASE
        WHEN p.status = 1 AND p.total_uses IS NOT NULL
             AND p.used_uses >= p.total_uses THEN 3
        WHEN p.status = 1 AND p.actual_expiry_date IS NOT NULL
             AND p.actual_expiry_date < clock_timestamp() THEN 4
        ELSE p.status
      END AS status,
      q.quota_used,
      q.quota_limit,
      s.quota_period,
      q.period_start AS quota_period_start,
      q.period_end AS quota_period_end,
      s.usage_limit_mode
    FROM service_purchases p
    JOIN users cu ON cu.id = p.client_id
    JOIN services s ON s.id = p.service_id
    JOIN service_types st ON st.id = s.service_type_id
    LEFT JOIN LATERAL (
      SELECT qp.quota_used, qp.quota_limit, qp.period_start, qp.period_end
        FROM purchase_quota_periods qp
       WHERE qp.purchase_id = p.id
         AND clock_timestamp() >= qp.period_start
         AND clock_timestamp() < qp.period_end
       ORDER BY qp.period_start DESC
       LIMIT 1
    ) q ON TRUE
  ''';

  @override
  Future<Map<String, dynamic>?> getClientRow(
    String clientId, {
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('''
        SELECT id, first_name, last_name, archived_at
          FROM users
         WHERE id = @id
      '''),
      parameters: {'id': clientId},
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first.toColumnMap();
  }

  @override
  Future<bool> hasActivePurchase({
    required String clientId,
    required String serviceId,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('''
        SELECT 1
          FROM service_purchases
         WHERE client_id = @clientId
           AND service_id = @serviceId
           AND status = 1
           AND (actual_expiry_date IS NULL OR actual_expiry_date >= NOW())
         LIMIT 1
      '''),
      parameters: {'clientId': clientId, 'serviceId': serviceId},
    );
    return rows.isNotEmpty;
  }

  @override
  Future<String> createPurchase({
    required String clientId,
    required String serviceId,
    required String soldBy,
    required double? purchasePrice,
    required double discountPercent,
    required double discountAmount,
    required double? finalPrice,
    required int paymentStatus,
    required int? paymentSource,
    required DateTime purchaseDate,
    required DateTime? activationDate,
    required DateTime? expiryDate,
    required DateTime? actualExpiryDate,
    required int? totalUses,
    required int status,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('''
        INSERT INTO service_purchases (
          client_id, service_id, sold_by,
          purchase_price, discount_percent, discount_amount, final_price,
          payment_status, payment_source, purchase_date,
          activation_date, expiry_date, actual_expiry_date,
          total_uses, used_uses, status, created_by, updated_by
        ) VALUES (
          @clientId, @serviceId, @soldBy,
          @purchasePrice, @discountPercent, @discountAmount, @finalPrice,
          @paymentStatus, @paymentSource, @purchaseDate,
          @activationDate, @expiryDate, @actualExpiryDate,
          @totalUses, 0, @status, @soldBy, @soldBy
        )
        RETURNING id
      '''),
      parameters: {
        'clientId': clientId,
        'serviceId': serviceId,
        'soldBy': soldBy,
        'purchasePrice': purchasePrice,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
        'finalPrice': finalPrice,
        'paymentStatus': paymentStatus,
        'paymentSource': paymentSource,
        'purchaseDate': purchaseDate,
        'activationDate': activationDate,
        'expiryDate': expiryDate,
        'actualExpiryDate': actualExpiryDate,
        'totalUses': totalUses,
        'status': status,
      },
    );
    return rows.first[0].toString();
  }

  @override
  Future<void> addParticipant({
    required String purchaseId,
    required String clientId,
    required String createdBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO purchase_participants (
          purchase_id, client_id, role, created_by
        ) VALUES (@purchaseId, @clientId, 1, @createdBy)
        ON CONFLICT (purchase_id, client_id) DO NOTHING
      '''),
      parameters: {
        'purchaseId': purchaseId,
        'clientId': clientId,
        'createdBy': createdBy,
      },
    );
  }

  @override
  Future<void> createQuotaPeriod({
    required String purchaseId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int quotaLimit,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        INSERT INTO purchase_quota_periods (
          purchase_id, period_start, period_end, quota_limit, quota_used,
          created_at
        ) VALUES (
          @purchaseId, @periodStart, @periodEnd, @quotaLimit, 0, NOW()
        )
        ON CONFLICT (purchase_id, period_start) DO NOTHING
      '''),
      parameters: {
        'purchaseId': purchaseId,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'quotaLimit': quotaLimit,
      },
    );
  }

  @override
  Future<List<ServicePurchase>> getClientServices(String clientId) async {
    final connection = await _db.connection;
    final rows = await connection.execute(
      Sql.named('''
        $_selectBase
         WHERE p.client_id = @clientId
           AND p.status IN (0, 1, 2, 3, 4)
         ORDER BY p.status, p.actual_expiry_date NULLS LAST, p.purchase_date DESC
      '''),
      parameters: {'clientId': clientId},
    );
    return rows.map(_toPurchase).toList();
  }

  @override
  Future<List<ServicePurchase>> getHistory({
    String? clientId,
    int? status,
  }) async {
    final connection = await _db.connection;
    final where = <String>['p.archived_at IS NULL'];
    final parameters = <String, dynamic>{};

    if (clientId != null && clientId.isNotEmpty) {
      where.add('p.client_id = @clientId');
      parameters['clientId'] = clientId;
    }
    if (status != null) {
      where.add('p.status = @status');
      parameters['status'] = status;
    }

    final rows = await connection.execute(
      Sql.named('''
        $_selectBase
         WHERE ${where.join(' AND ')}
         ORDER BY p.purchase_date DESC
      '''),
      parameters: parameters,
    );
    return rows.map(_toPurchase).toList();
  }

  /// Покупка по id после создания; отдельно нужна для ответа API.
  @override
  Future<ServicePurchase?> getById(String id, {Session? session}) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('$_selectBase WHERE p.id = @id'),
      parameters: {'id': id},
    );
    if (rows.isEmpty) {
      return null;
    }
    return _toPurchase(rows.first);
  }

  @override
  Future<Map<String, dynamic>?> getRowById(
    String id, {
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('''
        SELECT
          p.id, p.client_id, p.status, p.total_uses, p.used_uses,
          p.activation_date, p.expiry_date, p.actual_expiry_date,
          s.duration_days,
          s.usage_limit_mode,
          s.quota_period,
          s.quota_limit,
          s.activation_required
        FROM service_purchases p
        JOIN services s ON s.id = p.service_id
        WHERE p.id = @id
        FOR UPDATE OF p
      '''),
      parameters: {'id': id},
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first.toColumnMap();
  }

  @override
  Future<void> activate({
    required String id,
    required DateTime activationDate,
    required DateTime? expiryDate,
    required DateTime? actualExpiryDate,
    required String updatedBy,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE service_purchases
           SET status = 1,
               activation_date = @activationDate,
               expiry_date = @expiryDate,
               actual_expiry_date = @actualExpiryDate,
               updated_at = NOW(),
               updated_by = @updatedBy
         WHERE id = @id
      '''),
      parameters: {
        'id': id,
        'activationDate': activationDate,
        'expiryDate': expiryDate,
        'actualExpiryDate': actualExpiryDate,
        'updatedBy': updatedBy,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDueForStatusUpdate({
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    final rows = await conn.execute(
      Sql.named('''
        SELECT id, status, total_uses, used_uses
          FROM service_purchases
         WHERE status = 1
           AND (
             (total_uses IS NOT NULL AND used_uses >= total_uses)
             OR (actual_expiry_date IS NOT NULL
                 AND actual_expiry_date < clock_timestamp())
           )
         FOR UPDATE
      '''),
    );
    return rows.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<void> updateStatus({
    required String id,
    required int status,
    Session? session,
  }) async {
    final conn = session ?? await _db.connection;
    await conn.execute(
      Sql.named('''
        UPDATE service_purchases
           SET status = @status, updated_at = NOW()
         WHERE id = @id
      '''),
      parameters: {'id': id, 'status': status},
    );
  }

  ServicePurchase _toPurchase(ResultRow row) {
    final map = row.toColumnMap();
    return ServicePurchase(
      id: map['id'].toString(),
      clientId: map['client_id'].toString(),
      clientName: map['client_name'] as String?,
      serviceId: map['service_id'].toString(),
      serviceName: map['service_name'].toString(),
      serviceCode: map['service_code']?.toString(),
      serviceTypeCode: map['service_type_code']?.toString(),
      serviceTypeTitle: map['service_type_title']?.toString(),
      purchasePrice: (map['purchase_price'] as num?)?.toDouble(),
      discountPercent: (map['discount_percent'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num).toDouble(),
      finalPrice: (map['final_price'] as num?)?.toDouble(),
      paymentStatus: map['payment_status'] as int,
      paymentSource: map['payment_source'] as int?,
      purchaseDate: map['purchase_date'] as DateTime,
      activationDate: map['activation_date'] as DateTime?,
      expiryDate: map['expiry_date'] as DateTime?,
      actualExpiryDate: map['actual_expiry_date'] as DateTime?,
      totalUses: map['total_uses'] as int?,
      usedUses: map['used_uses'] as int,
      remainingUses: map['remaining_uses'] as int?,
      status: map['status'] as int,
      quotaUsed: map['quota_used'] as int?,
      quotaLimit: map['quota_limit'] as int?,
      quotaPeriod: map['quota_period'] as int?,
      quotaPeriodStart: map['quota_period_start'] as DateTime?,
      quotaPeriodEnd: map['quota_period_end'] as DateTime?,
      usageLimitMode: map['usage_limit_mode'] as int,
    );
  }
}
