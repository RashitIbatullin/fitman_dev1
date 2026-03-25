import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';
import 'package:fitman_app/modules/equipment/widgets/maintenance_status_history_widget.dart';

class MaintenanceStatusHistoryScreen extends ConsumerWidget {
  final String maintenanceId;

  const MaintenanceStatusHistoryScreen({
    required this.maintenanceId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceHistoryAsync = ref.watch(singleMaintenanceHistoryByIdProvider(maintenanceId));

    return maintenanceHistoryAsync.when(
      data: (history) {
        final equipmentItemAsync = ref.watch(equipmentItemByIdProvider(history.equipmentItemId));

        return Scaffold(
          appBar: AppBar(
            title: equipmentItemAsync.when(
              data: (equipment) {
                final equipmentDisplayName =
                    '${equipment.manufacturer ?? ''} ${equipment.model ?? ''}';
                final finalDisplayName = equipmentDisplayName.trim().isNotEmpty
                    ? equipmentDisplayName.trim()
                    : equipment.inventoryNumber;
                return Text(
                  'Заявка №${history.number}: $finalDisplayName',
                  overflow: TextOverflow.ellipsis,
                );
              },
              loading: () => Text('Заявка №${history.number}...'),
              error: (e, s) => Text('Заявка №${history.number}'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: MaintenanceStatusHistoryWidget(history: history),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Загрузка...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(child: Text('Ошибка загрузки: $error')),
      ),
    );
  }
}
