import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceStatusHistoryWidget extends StatelessWidget {
  final List<MaintenanceStatusHistoryRecord> historyRecords;

  const MaintenanceStatusHistoryWidget({
    super.key,
    required this.historyRecords,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: historyRecords.length,
      itemBuilder: (context, index) {
        final record = historyRecords[index];
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(record.changedAt.toLocal());
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text('Новый статус: ${record.newStatus.title}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record.oldStatus != null)
                  Text('Старый статус: ${record.oldStatus!.title}'),
                const SizedBox(height: 4),
                Text('Изменил: ${record.changedByName ?? 'N/A'}'),
                Text('Время: $formattedDate'),
                if (record.comment != null && record.comment!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('Комментарий: ${record.comment!}', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}