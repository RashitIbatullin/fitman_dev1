import 'package:fitman_backend/audit/audit_context.dart';
import 'package:fitman_backend/audit/audit_service.dart';
import 'package:fitman_backend/config/database.dart';
import 'package:fitman_backend/logging/app_logger.dart';
import 'package:fitman_backend/modules/services/repositories/service_purchase_repository.dart';
import 'package:fitman_common/fitman_common.dart';

/// Автоматическое закрытие покупок: исчерпание остатка и истечение срока.
///
/// Запускается при старте сервера и по таймеру. Статус переводится
/// в `exhausted` или `expired`, каждое изменение пишется в аудит.
class ServicePurchaseMaintenance {
  ServicePurchaseMaintenance(this._repository, this._database);

  final ServicePurchaseRepository _repository;
  final Database _database;
  final AuditService _auditService = const AuditService();

  Future<int> expireOverdue() {
    return _database.runTx((session) async {
      final rows = await _repository.getDueForStatusUpdate(session: session);
      if (rows.isEmpty) {
        return 0;
      }

      final audit = AuditContext.system();
      for (final row in rows) {
        final id = row['id'].toString();
        final currentStatus = row['status'] as int;
        final totalUses = row['total_uses'] as int?;
        final usedUses = row['used_uses'] as int;
        final exhausted = totalUses != null && usedUses >= totalUses;
        final newStatus = exhausted
            ? ServicePurchaseStatus.exhausted
            : ServicePurchaseStatus.expired;

        await _repository.updateStatus(
          id: id,
          status: newStatus,
          session: session,
        );
        await _auditService.record(
          session: session,
          tableName: 'service_purchases',
          rowPk: id,
          action: 'UPDATE',
          context: audit,
          oldValues: {'status': currentStatus},
          newValues: {'status': newStatus},
          reason: 'Автоматическое закрытие покупки',
        );
      }

      appLog.info(
        'Автоматически закрыты покупки',
        fields: {
          'entity': 'service_purchases',
          'count': rows.length,
        },
      );
      return rows.length;
    });
  }
}
