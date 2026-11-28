import 'package:fitman_backend/modules/audit/repositories/audit_repository.dart';

/// Чтение журнала аудита для администратора.
class AuditQueryService {
  AuditQueryService(this._repository);

  final AuditRepository _repository;

  Future<AuditPage> getPage({
    String? tableName,
    String? action,
    DateTime? from,
    DateTime? to,
    required int limit,
    required int offset,
  }) {
    final safeLimit = limit.clamp(1, 200);
    final safeOffset = offset < 0 ? 0 : offset;
    return _repository.getPage(
      tableName: tableName,
      action: action,
      from: from,
      to: to,
      limit: safeLimit,
      offset: safeOffset,
    );
  }
}
