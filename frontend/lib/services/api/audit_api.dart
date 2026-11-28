import 'package:fitman_common/fitman_common.dart';

import 'base_api.dart';

/// Страница журнала аудита.
class AuditPage {
  const AuditPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final List<AuditRecord> items;
  final int total;
  final int limit;
  final int offset;
}

/// Чтение журнала аудита (только администратор).
class AuditApiService extends BaseApiService {
  AuditApiService({super.client});

  Future<AuditPage> getRecords({
    String? tableName,
    String? action,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (tableName != null && tableName.isNotEmpty) {
      query['tableName'] = tableName;
    }
    if (action != null && action.isNotEmpty) {
      query['action'] = action;
    }
    if (from != null) {
      query['from'] = from.toUtc().toIso8601String();
    }
    if (to != null) {
      query['to'] = to.toUtc().toIso8601String();
    }

    final data = await get('/api/audit', queryParams: query);
    final map = data as Map<String, dynamic>;
    final items = (map['items'] as List<dynamic>)
        .map((item) => AuditRecord.fromJson(item as Map<String, dynamic>))
        .toList();

    return AuditPage(
      items: items,
      total: (map['total'] as num).toInt(),
      limit: (map['limit'] as num).toInt(),
      offset: (map['offset'] as num).toInt(),
    );
  }
}
