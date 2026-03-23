import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_item_detail_screen.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilteredEquipmentList extends ConsumerWidget {
  const FilteredEquipmentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems = ref.watch(filteredDashboardEquipmentProvider);
    final activeFilter = ref.watch(dashboardEquipmentFilterProvider);
    final textTheme = Theme.of(context).textTheme;

    final String title;
    if (activeFilter == null) {
      title = 'Все оборудование';
    } else {
      title = 'Оборудование: ${activeFilter.displayName}';
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              'Нет оборудования в статусе "${activeFilter?.displayName ?? 'Все'}"'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleLarge),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final displayName = [item.manufacturer, item.model]
                .where((s) => s != null && s.isNotEmpty)
                .join(' ');
            final finalName =
                displayName.isNotEmpty ? displayName : item.inventoryNumber;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(finalName),
                subtitle: Text('Инв. номер: ${item.inventoryNumber}'),
                trailing: Chip(
                  label: Text(item.status.displayName),
                  backgroundColor: item.status.color.withAlpha((255 * 0.2).round()),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EquipmentItemDetailScreen(
                        itemId: item.id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
