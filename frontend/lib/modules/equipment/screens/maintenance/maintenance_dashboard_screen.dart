import 'package:fitman_app/modules/equipment/widgets/equipment_stats_card.dart';
import 'package:fitman_app/modules/equipment/widgets/filtered_equipment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceDashboardScreen extends ConsumerWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ТО оборудования'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate providers to refetch data
          // ref.invalidate(allEquipmentItemsProvider);
          // ref.invalidate(allMaintenanceHistoryProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              EquipmentStatsCard(),
              SizedBox(height: 24),
              FilteredEquipmentList(),
              SizedBox(height: 24),
              // Other dashboard widgets will go here
            ],
          ),
        ),
      ),
    );
  }
}
