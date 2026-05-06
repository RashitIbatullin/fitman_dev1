import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';
import 'package:fitman_app/modules/equipment/widgets/maintenance_status_history_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceStatusHistoryScreen extends ConsumerWidget {
  final String maintenanceId;

  const MaintenanceStatusHistoryScreen({
    required this.maintenanceId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusHistoryAsync = ref.watch(maintenanceStatusHistoryProvider(maintenanceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('История статусов заявки'),
      ),
      body: statusHistoryAsync.when(
        data: (historyRecords) {
          if (historyRecords.isEmpty) {
            return const Center(child: Text('История статусов пуста.'));
          }
          return MaintenanceStatusHistoryWidget(historyRecords: historyRecords);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки истории: $error')),
      ),
    );
  }
}
