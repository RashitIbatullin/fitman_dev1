import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_item_detail_screen.dart';
import 'package:fitman_app/modules/equipment/utils/schematic_icons.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/extensions/equipment_ui_extensions.dart';
import 'package:collection/collection.dart';

class FilteredEquipmentList extends ConsumerWidget {
  const FilteredEquipmentList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems = ref.watch(filteredDashboardEquipmentProvider);
    final activeFilter = ref.watch(dashboardEquipmentFilterProvider);
    final allTypesAsync = ref.watch(allEquipmentTypesIncludingArchivedProvider);
    final textTheme = Theme.of(context).textTheme;

    final String title;
    if (activeFilter == null) {
      title = 'Все оборудование';
    } else {
      title = 'Оборудование: ${activeFilter.displayName}';
    }

    return allTypesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Ошибка загрузки типов: $err')),
      data: (allTypes) {
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
                final type =
                    allTypes.firstWhereOrNull((t) => t.id == item.typeId);
                final icon = getSchematicIcon(type?.schematicIcon);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(icon),
                    title: Text(
                        '${item.inventoryNumber} (${item.typeName ?? 'N/A'})'),
                    subtitle: Text(item.roomName ?? 'Помещение не назначено'),
                    trailing: Chip(
                      label: Text(item.status.displayName),
                      backgroundColor:
                          item.status.color.withAlpha((255 * 0.2).round()),
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
      },
    );
  }
}
