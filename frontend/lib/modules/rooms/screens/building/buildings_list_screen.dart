import 'package:fitman_app/modules/rooms/models/building/building.model.dart';
import 'package:fitman_app/modules/rooms/providers/room/building_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/widgets/filter_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'building_create_screen.dart';
import 'building_detail_screen.dart';
import 'building_edit_screen.dart';

final buildingIsArchivedFilterProvider = StateProvider<bool?>((ref) => false);

class BuildingsListScreen extends ConsumerStatefulWidget {
  const BuildingsListScreen({super.key});

  @override
  ConsumerState<BuildingsListScreen> createState() =>
      _BuildingsListScreenState();
}

class _BuildingsListScreenState extends ConsumerState<BuildingsListScreen> {
  final TextEditingController _archiveReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _archiveReasonController.dispose();
    super.dispose();
  }

  Future<void> _performArchive(Building building, String reason) async {
    try {
      final updatedBuilding = building.copyWith(
        archivedAt: DateTime.now(),
        archivedReason: reason,
      );
      await ApiService.updateBuilding(building.id, updatedBuilding);
      ref.invalidate(allBuildingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Здание архивировано'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка архивации: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showArchiveBuildingDialog(Building building) async {
    _archiveReasonController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Архивировать здание'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Вы уверены, что хотите архивировать здание "${building.name}"?'),
              TextFormField(
                controller: _archiveReasonController,
                decoration: const InputDecoration(
                  hintText: 'Причина архивации (не менее 5 символов)*',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Причина должна содержать не менее 5 символов.';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Архивировать'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performArchive(building, _archiveReasonController.text.trim());
    }
  }

  Future<void> _unarchiveBuilding(Building building) async {
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите восстановление'),
        content: Text('Вы уверены, что хотите восстановить здание "${building.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Восстановить')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final updatedBuilding = building.copyWith(
        archivedAt: null,
        archivedReason: null, // Clear the reason when unarchiving
      );
      await ApiService.updateBuilding(building.id, updatedBuilding);
      ref.invalidate(allBuildingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Здание восстановлено из архива'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка восстановления: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);
    final isArchivedFilter = ref.watch(buildingIsArchivedFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Здания'),
        actions: [
          FilterPopupMenuButton<bool?>(
            tooltip: 'Статус',
            allOptionText: 'Статус: Все',
            initialValue: isArchivedFilter,
            avatar: const Icon(Icons.archive_outlined),
            onSelected: (value) {
              ref.read(buildingIsArchivedFilterProvider.notifier).state = value;
            },
            options: const [
              FilterOption(label: 'Не в архиве', value: false),
              FilterOption(label: 'В архиве', value: true),
            ],
            showAllOption: true,
          ),
        ],
      ),
      body: buildingsAsync.when(
        data: (buildings) {
          if (buildings.isEmpty) {
            return const Center(child: Text('Здания не найдены.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(allBuildingsProvider.future),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: ListView.builder(
                itemCount: buildings.length,
                itemBuilder: (context, index) {
                  final building = buildings[index];
                  return Card(
                    color: building.archivedAt != null ? Colors.grey[200] : null,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      title: Text(building.name),
                      subtitle: Text(building.address),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BuildingDetailScreen(buildingId: building.id),
                          ),
                        );
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BuildingEditScreen(building: building),
                              ),
                            );
                            ref.read(allBuildingsProvider.notifier).refresh();
                          } else if (value == 'archive') {
                            _showArchiveBuildingDialog(building);
                          } else if (value == 'unarchive') {
                            _unarchiveBuilding(building);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          if (building.archivedAt == null) ...[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Изменить'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'archive',
                              child: Text('Архивировать'),
                            ),
                          ] else ...[
                            const PopupMenuItem<String>(
                              value: 'unarchive',
                              child: Text('Деархивировать'),
                            ),
                          ],
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_building_fab',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BuildingCreateScreen()),
          );
          ref.read(allBuildingsProvider.notifier).refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


