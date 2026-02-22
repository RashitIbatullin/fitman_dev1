import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/maintenance/providers/maintenance_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_maintenance_history_edit_screen.dart';

class MaintenanceDashboardScreen extends ConsumerWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(allMaintenanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Журнал ТО'),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('Нет записей в истории обслуживания.'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(record.descriptionOfWork),
                  subtitle: Text(
                      'Оборудование: ${record.equipmentItemId} - Отправлено: ${record.dateSent.toLocal().toString().substring(0, 10)}'),
                  trailing: record.cost != null ? Text('${record.cost} руб.') : null,
                  onTap: () {
                    // Note: This navigation might not be ideal since the edit screen is in the equipment module
                    // but it's what's available from previous steps.
                    Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => EquipmentMaintenanceHistoryEditScreen(
                          equipmentItemId: record.equipmentItemId,
                          historyRecord: record,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}
