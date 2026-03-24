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

    return Scaffold(
      appBar: AppBar(
        title: maintenanceHistoryAsync.when(
          data: (history) => Text('История статусов: Заявка №${history.number} - ${history.equipmentName} - ${history.reportedProblem}'),
          loading: () => const Text('Загрузка истории статусов...'),
          error: (error, stack) => const Text('Ошибка'),
        ),
      ),
      body: maintenanceHistoryAsync.when(
        data: (history) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: MaintenanceStatusHistoryWidget(history: history),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки: $error')),
      ),
    );
  }
}