import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:intl/intl.dart';

class MaintenanceDetailsScreen extends StatelessWidget {
  const MaintenanceDetailsScreen({super.key, required this.record});

  final EquipmentMaintenanceHistory record;

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

    // Helper to format dates safely
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
    }

    final beforePhotos = record.photos?.where((p) => p.timing == PhotoTiming.before).toList() ?? [];
    final afterPhotos = record.photos?.where((p) => p.timing == PhotoTiming.after).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(record.equipmentName ?? 'Заявка на ТО'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(label: 'Проблема:', value: record.reportedProblem),
            const Divider(),
            _buildDetailRow(label: 'Статус:', value: record.status.title),
            _buildDetailRow(label: 'Тип:', value: record.type.title),
            if (record.workDescription != null && record.workDescription!.isNotEmpty)
              _buildDetailRow(label: 'Выполненные работы:', value: record.workDescription!),
            
            const Divider(height: 32),
            Text('Исполнители', style: Theme.of(context).textTheme.titleLarge),
            _buildDetailRow(label: 'Заявил:', value: record.reportedBy), // TODO: Fetch user name
            if (record.assignedToUserId != null)
              _buildDetailRow(label: 'Назначено (сотрудник):', value: record.assignedToUserId!.toString()), // TODO: Fetch user name
            if (record.assignedToStaffId != null)
               _buildDetailRow(label: 'Назначено (внешний):', value: record.assignedToStaffId!.toString()), // TODO: Fetch staff name
            
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
}
