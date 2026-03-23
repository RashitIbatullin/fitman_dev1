import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentStatsCard extends ConsumerWidget {
  const EquipmentStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(equipmentStatsProvider);
    final theme = Theme.of(context);
    final activeFilter = ref.watch(dashboardEquipmentFilterProvider);

    void setFilter(EquipmentStatus? status) {
      ref.read(dashboardEquipmentFilterProvider.notifier).state = status;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.spaceAround,
          children: [
            _StatTile(
              title: 'Всего',
              value: stats.total.toString(),
              color: theme.colorScheme.secondary,
              isActive: activeFilter == null,
              onTap: () => setFilter(null),
            ),
            _StatTile(
              title: 'Доступно',
              value: stats.available.toString(),
              color: Colors.green,
              isActive: activeFilter == EquipmentStatus.available,
              onTap: () => setFilter(EquipmentStatus.available),
            ),
            _StatTile(
              title: 'В работе',
              value: stats.inUse.toString(),
              color: Colors.blue,
              isActive: activeFilter == EquipmentStatus.inUse,
              onTap: () => setFilter(EquipmentStatus.inUse),
            ),
            _StatTile(
              title: 'На ТО',
              value: stats.inMaintenance.toString(),
              color: Colors.orange,
              isActive: activeFilter == EquipmentStatus.maintenance,
              onTap: () => setFilter(EquipmentStatus.maintenance),
            ),
            _StatTile(
              title: 'Неисправно',
              value: stats.outOfOrder.toString(),
              color: theme.colorScheme.error,
              isActive: activeFilter == EquipmentStatus.outOfOrder,
              onTap: () => setFilter(EquipmentStatus.outOfOrder),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    this.color,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String value;
  final Color? color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary.withAlpha((255 * 0.1).round()) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
