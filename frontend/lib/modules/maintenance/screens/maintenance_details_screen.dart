import 'package:flutter/material.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:intl/intl.dart';

class MaintenanceDetailsScreen extends StatelessWidget {
  const MaintenanceDetailsScreen({super.key, required this.record});

  final EquipmentMaintenanceHistory record;

  @override
  Widget build(BuildContext context) {
    // Helper to format dates safely
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
    }

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
            _buildDetailRow(label: 'Статус:', value: record.status.name),
            _buildDetailRow(label: 'Тип:', value: record.type.name),
            if (record.workDescription != null && record.workDescription!.isNotEmpty)
              _buildDetailRow(label: 'Выполненные работы:', value: record.workDescription!),
            
            const Divider(height: 32),
            Text('Исполнители', style: Theme.of(context).textTheme.titleLarge),
            _buildDetailRow(label: 'Заявил:', value: record.reportedBy), // TODO: Fetch user name
            if (record.assignedToUserId != null)
              _buildDetailRow(label: 'Назначено (сотрудник):', value: record.assignedToUserId!), // TODO: Fetch user name
            if (record.assignedToStaffId != null)
               _buildDetailRow(label: 'Назначено (внешний):', value: record.assignedToStaffId!), // TODO: Fetch staff name
            
            const Divider(height: 32),
            Text('Сроки', style: Theme.of(context).textTheme.titleLarge),
            _buildDetailRow(label: 'Создана:', value: formatDate(record.createdAt)),
            _buildDetailRow(label: 'Начата:', value: formatDate(record.startedAt)),
            _buildDetailRow(label: 'Завершена:', value: formatDate(record.completedAt)),
            
            if (record.photos != null && record.photos!.isNotEmpty) ...[
              const Divider(height: 32),
              Text('Фотографии:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...record.photos!.map((photo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(photo.url, height: 200, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error, size: 40)),
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
