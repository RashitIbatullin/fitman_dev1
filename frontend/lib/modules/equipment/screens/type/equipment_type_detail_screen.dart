import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'equipment_type_edit_screen.dart';

class EquipmentTypeDetailScreen extends ConsumerWidget {
  final String equipmentTypeId;

  const EquipmentTypeDetailScreen({
    super.key,
    required this.equipmentTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentTypeAsyncValue = ref.watch(equipmentTypeByIdProvider(equipmentTypeId));

    return Scaffold(
      appBar: AppBar(
        title: equipmentTypeAsyncValue.when(
          data: (equipmentType) => Text(equipmentType.name),
          loading: () => const Text('Загрузка...'),
          error: (error, stack) => const Text('Ошибка'),
        ),
        actions: [
          equipmentTypeAsyncValue.when(
            data: (equipmentType) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EquipmentTypeEditScreen(
                      equipmentTypeId: equipmentType.id,
                      // Pass the existing equipmentType object to the edit screen
                      // to pre-fill the form.
                      equipmentType: equipmentType,
                    ),
                  ),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: equipmentTypeAsyncValue.when(
        data: (equipmentType) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (equipmentType.schematicIcon != null && equipmentType.schematicIcon!.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Icon(
                        _getSchematicIcon(equipmentType.schematicIcon!),
                        size: 100, // Adjust size as needed
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                _buildDetailRow(
                  label: 'Название:',
                  value: equipmentType.name,
                ),
                if (equipmentType.description != null && equipmentType.description!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Описание:',
                    value: equipmentType.description!,
                  ),
                _buildDetailRow(
                  label: 'Категория:',
                  value: equipmentType.category.displayName,
                ),
                if (equipmentType.weightRange != null && equipmentType.weightRange!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Диапазон веса:',
                    value: equipmentType.weightRange!,
                  ),
                if (equipmentType.dimensions != null && equipmentType.dimensions!.isNotEmpty)
                  _buildDetailRow(
                    label: 'Габариты:',
                    value: equipmentType.dimensions!,
                  ),

                _buildDetailRow(
                  label: 'Мобильное:',
                  value: equipmentType.isMobile ? 'Да' : 'Нет',
                ),



              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }


IconData _getSchematicIcon(String iconName) {
  switch (iconName) {
    case 'dumbbell':
      return Icons.fitness_center;
    case 'treadmill':
      return Icons.directions_run;
    case 'bike':
      return Icons.pedal_bike;
    case 'elliptical':
      return Icons.directions_walk;
    case 'barbell':
      return Icons.sports_gymnastics;
    case 'bench':
      return Icons.chair; // Placeholder
    case 'leg_press':
      return Icons.view_sidebar; // Placeholder
    case 'fitball':
      return Icons.sports_basketball; // Placeholder
    case 'yoga_mat':
      return Icons.spa; // Using spa for yoga mat
    case 'scales':
      return Icons.scale;
    case 'crossover':
      return Icons.cable; // Placeholder icon
    case 'kettlebell':
      return Icons.fitness_center; // Placeholder icon
    case 'pull_block':
      return Icons.sports_gymnastics; // Placeholder icon
    case 'stepper':
      return Icons.directions_walk; // Placeholder icon
    case 'hammer_chest':
      return Icons.fitness_center; // Placeholder icon
    case 'aerobic_step':
      return Icons.directions_walk; // Placeholder icon
    case 'punching_bag':
      return Icons.sports_mma; // Placeholder icon
    default:
      return Icons.category; // Default icon if not found
  }
}

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}