import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart'; // Add this import
import '../../providers/room/building_provider.dart';
import 'building_edit_screen.dart';

class BuildingDetailScreen extends ConsumerWidget {
  final String buildingId;

  const BuildingDetailScreen({super.key, required this.buildingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали здания'),
        actions: [
          buildingsAsync.when(
            data: (buildings) {
              final building = buildings.firstWhereOrNull((b) => b.id == buildingId);
              if (building == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BuildingEditScreen(building: building),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          )
        ],
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          final building = buildings.firstWhereOrNull((b) => b.id == buildingId);
          if (building == null) {
            return const Center(child: Text('Здание не найдено.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allBuildingsProvider.future),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, 'Название:', building.name),
                  _buildInfoRow(context, 'Адрес:', building.address),
                  _buildInfoRow(context, 'Заметка:', building.note ?? 'Нет'),
                  const SizedBox(height: 16.0),
                  if (building.archivedAt != null)
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            context,
                            'Статус:',
                            'В архиве',
                            valueColor: Colors.orange,
                          ),
                          _buildInfoRow(
                            context,
                            'Архивировано:',
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(building.archivedAt!.toLocal()),
                          ),
                          if (building.archivedByName?.isNotEmpty == true)
                            _buildInfoRow(
                              context,
                              'Кем архивировано:',
                              building.archivedByName!,
                            ),
                          if (building.archivedReason?.isNotEmpty == true)
                            _buildInfoRow(
                              context,
                              'Причина архивации:',
                              building.archivedReason!,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Adjusted width for better spacing
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
