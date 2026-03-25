import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/equipment_maintenance_history.model.dart';

class MaintenanceStatusHistoryWidget extends StatelessWidget {
  const MaintenanceStatusHistoryWidget({
    required this.history,
    super.key,
  });

  final EquipmentMaintenanceHistory history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    Widget buildRow(String status, String? person, DateTime? date) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(status, style: theme.textTheme.bodyMedium)),
            Expanded(
              flex: 3,
              child: Text(
                person ?? '---',
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                date != null ? dateFormat.format(date) : '---',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text('Статус', style: theme.textTheme.labelSmall)),
                  Expanded(flex: 3, child: Text('Пользователь', style: theme.textTheme.labelSmall)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Время',
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            buildRow('Заявка', history.reportedByName, history.createdAt),
            if (history.startedAt != null || history.status == MaintenanceStatus.inProgress)
              buildRow('В работе', history.inProgressByName, history.startedAt),
            if (history.completedAt != null || history.status == MaintenanceStatus.completed)
              buildRow('Завершено', history.completedByName, history.completedAt),
            if (history.cancelledAt != null || history.status == MaintenanceStatus.cancelled)
              buildRow('Отмена', history.cancelledByName, history.cancelledAt),
          ],
        ),
      ),
    );
  }
}