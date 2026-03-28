import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/screens/maintenance_status_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart';

class MaintenanceDetailsScreen extends ConsumerWidget { // Changed to ConsumerWidget
  const MaintenanceDetailsScreen({super.key, required this.record});

  final EquipmentMaintenanceHistory record;

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

    // Helper to format dates safely
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
    }

    final beforePhotos = record.photos?.where((p) => p.timing == PhotoTiming.before).toList() ?? [];
    final afterPhotos = record.photos?.where((p) => p.timing == PhotoTiming.after).toList() ?? [];

    // Watch the equipment item to get its name
    final equipmentItemAsync = ref.watch(equipmentItemByIdProvider(record.equipmentItemId));

    return Scaffold(
      appBar: AppBar(
        title: equipmentItemAsync.when(
          data: (equipment) {
            final equipmentDisplayName =
                '${equipment.manufacturer ?? ''} ${equipment.model ?? ''}'.trim();
            final finalDisplayName = equipmentDisplayName.isNotEmpty
                ? equipmentDisplayName
                : equipment.inventoryNumber;
            return Text(
              'Заявка №${record.number}: $finalDisplayName',
              overflow: TextOverflow.ellipsis,
            );
          },
          loading: () => Text('Заявка №${record.number}...'), // Fallback while loading equipment
          error: (e, s) => Text('Заявка №${record.number}'), // Fallback on error
        ),
        actions: [
          if (record.id != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MaintenanceStatusHistoryScreen(
                        maintenanceId: record.id!,
                      ),
                    ),
                  );
                },
                child: const Text('История статусов'),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.number != null)
              _buildDetailRow(label: 'Номер заявки:', value: record.number!),
            _buildDetailRow(label: 'Проблема:', value: record.reportedProblem),
            if (record.notes != null && record.notes!.isNotEmpty)
              _buildDetailRow(label: 'Примечания:', value: record.notes!),
            const Divider(),
            _buildDetailRow(label: 'Статус:', value: record.status.title),
            _buildDetailRow(label: 'Тип:', value: record.type.title),
            if (record.workDescription != null && record.workDescription!.isNotEmpty)
              _buildDetailRow(label: 'Выполненные работы:', value: record.workDescription!),
            if (record.status == MaintenanceStatus.cancelled && record.cancellationReason != null && record.cancellationReason!.isNotEmpty)
              _buildDetailRow(label: 'Причина отмены:', value: record.cancellationReason!),
            
            const Divider(height: 32),
            Text('Исполнители', style: Theme.of(context).textTheme.titleLarge),
            ReportedByInfo(userId: record.reportedBy),
            if (record.executorName != null)
              _buildDetailRow(label: 'Исполнитель:', value: record.executorName!),
            
            const Divider(height: 32),
            Text('Сроки', style: Theme.of(context).textTheme.titleLarge),
            _buildDetailRow(label: 'Создана:', value: formatDate(record.createdAt)),
            _buildDetailRow(label: 'Начата:', value: formatDate(record.startedAt)),
            _buildDetailRow(label: 'Завершена:', value: formatDate(record.completedAt)),
            
            if (beforePhotos.isNotEmpty) ...[
              const Divider(height: 32),
              Text('Фото "До":', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...beforePhotos.map((photo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network('$baseUrl${photo.url}', height: 200, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 40)),
                    if (photo.comment != null && photo.comment!.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Примечание: ${photo.comment}'),
                      ),
                  ],
                ),
              )),
            ],

            if (afterPhotos.isNotEmpty) ...[
              const Divider(height: 32),
              Text('Фото "После":', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...afterPhotos.map((photo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network('$baseUrl${photo.url}', height: 200, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 40)),
                    if (photo.comment != null && photo.comment!.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Примечание: ${photo.comment}'),
                      ),
                  ],
                ),
              )),
            ]
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailRow({required String label, required String value}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

class ReportedByInfo extends ConsumerWidget {
  const ReportedByInfo({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      data: (user) => _buildDetailRow(label: 'Заявил:', value: user.shortName),
      loading: () => _buildDetailRow(label: 'Заявил:', value: 'Загрузка...'),
      error: (err, stack) => _buildDetailRow(label: 'Заявил:', value: 'Ошибка'),
    );
  }
}
