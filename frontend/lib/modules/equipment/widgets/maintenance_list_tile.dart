import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_maintenance_history_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MaintenanceListTile extends ConsumerWidget {
  const MaintenanceListTile({super.key, required this.historyItem});

  final EquipmentMaintenanceHistory historyItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the equipment item details to ensure the name is up-to-date
    final equipmentAsync =
        ref.watch(equipmentItemByIdProvider(historyItem.equipmentItemId));
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: equipmentAsync.when(
        data: (equipment) {
          final displayName = [equipment.manufacturer, equipment.model]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
          final finalName = displayName.isNotEmpty
              ? displayName
              : equipment.inventoryNumber;

          return ListTile(
            title: Text(finalName), // Use the constructed name
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Проблема: ${historyItem.reportedProblem}'),
                if (historyItem.createdAt != null)
                  Text(
                    'Заявка от: ${DateFormat('dd.MM.yyyy HH:mm').format(historyItem.createdAt!.toLocal())}',
                    style: textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        EquipmentMaintenanceHistoryEditScreen(
                      equipmentItemId: historyItem.equipmentItemId,
                      historyRecord: historyItem,
                    ),
                  ),
                );
              },
              child: const Text('Начать ремонт'),
            ),
          );
        },
        loading: () => const ListTile(
          title: Text('Загрузка названия...'),
          subtitle: Text('...'),
          trailing: CircularProgressIndicator(),
        ),
        error: (error, stack) => ListTile(
          title: const Text(
            'Не удалось загрузить название',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: Text(historyItem.reportedProblem),
        ),
      ),
    );
  }
}
