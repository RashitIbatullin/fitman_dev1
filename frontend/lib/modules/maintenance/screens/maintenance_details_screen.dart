import 'package:flutter/material.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';

class MaintenanceDetailsScreen extends StatelessWidget {
  const MaintenanceDetailsScreen({super.key, required this.record});

  final EquipmentMaintenanceHistory record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Запись ТО от ${record.dateSent.toLocal().toString().substring(0, 10)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(label: 'Оборудование:', value: record.equipmentItemId),
            _buildDetailRow(label: 'Описание:', value: record.descriptionOfWork),
            _buildDetailRow(label: 'Дата отправки:', value: record.dateSent.toLocal().toString().substring(0, 10)),
            if (record.dateReturned != null)
              _buildDetailRow(label: 'Дата возврата:', value: record.dateReturned!.toLocal().toString().substring(0, 10)),
            if (record.cost != null)
              _buildDetailRow(label: 'Стоимость:', value: '${record.cost} руб.'),
            if (record.performedBy != null)
              _buildDetailRow(label: 'Кем выполнено:', value: record.performedBy!),
            if (record.photos != null && record.photos!.isNotEmpty) ...[
              const Divider(height: 32),
              Text('Фотографии:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...record.photos!.map((photo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(photo.url, height: 150, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.error)),
                    if (photo.note.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Примечание: ${photo.note}'),
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
            width: 120,
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
