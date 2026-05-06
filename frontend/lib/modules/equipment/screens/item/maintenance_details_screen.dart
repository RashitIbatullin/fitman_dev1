import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/screens/item/equipment_maintenance_history_edit_screen.dart';
import 'package:fitman_app/modules/equipment/screens/maintenance_status_history_screen.dart';
import 'package:fitman_common/modules/equipment/equipment_maintenance_history.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';

class MaintenanceDetailsScreen extends ConsumerWidget {
  final String maintenanceId;

  const MaintenanceDetailsScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceHistoryAsync = ref.watch(singleMaintenanceHistoryByIdProvider(maintenanceId));

    return maintenanceHistoryAsync.when(
      data: (history) {
        final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

        String formatDate(DateTime? date) {
          if (date == null) return 'N/A';
          return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
        }

        final beforePhotos = history.photos?.where((p) => p.timing == PhotoTiming.before).toList() ?? [];
        final afterPhotos = history.photos?.where((p) => p.timing == PhotoTiming.after).toList() ?? [];

        final equipmentItemAsync = ref.watch(equipmentItemByIdProvider(history.equipmentItemId));

        return Scaffold(
          appBar: AppBar(
            title: equipmentItemAsync.when(
              data: (equipment) {
                return Text(
                  'Заявка № ${history.number}: ${equipment.inventoryNumber}',
                  overflow: TextOverflow.ellipsis,
                );
              },
              loading: () => Text('Заявка № ${history.number}...'),
              error: (e, s) => Text('Заявка № ${history.number}'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EquipmentMaintenanceHistoryEditScreen(
                        equipmentItemId: history.equipmentItemId,
                        historyRecord: history,
                      ),
                    ),
                  );
                },
                child: const Text('Редактировать'),
              ),
              if (history.id != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MaintenanceStatusHistoryScreen(
                            maintenanceId: history.id!,
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
                if (history.number != null)
                  _buildDetailRow(label: 'Номер заявки:', value: history.number!),
                _buildDetailRow(label: 'Проблема:', value: history.reportedProblem),
                if (history.notes != null && history.notes!.isNotEmpty)
                  _buildDetailRow(label: 'Примечания:', value: history.notes!),
                const Divider(),
                _buildDetailRow(label: 'Статус:', value: history.status.title),
                _buildDetailRow(label: 'Тип:', value: history.type.title),
                if (history.workDescription != null && history.workDescription!.isNotEmpty)
                  _buildDetailRow(label: 'Выполненные работы:', value: history.workDescription!),
                if (history.status == MaintenanceStatus.cancelled && history.cancellationReason != null && history.cancellationReason!.isNotEmpty)
                  _buildDetailRow(label: 'Причина отмены:', value: history.cancellationReason!),
                
                const Divider(height: 32),
                Text('Исполнители', style: Theme.of(context).textTheme.titleLarge),
                ReportedByInfo(userId: history.reportedBy),
                if (history.executorName != null)
                  _buildDetailRow(label: 'Исполнитель:', value: history.executorName!),
                
                const Divider(height: 32),
                Text('Сроки', style: Theme.of(context).textTheme.titleLarge),
                _buildDetailRow(label: 'Создана:', value: formatDate(history.createdAt)),
                _buildDetailRow(label: 'Начата:', value: formatDate(history.startedAt)),
                _buildDetailRow(label: 'Завершена:', value: formatDate(history.completedAt)),
                
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
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Загрузка заявки...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(child: Text('Ошибка загрузки заявки: $error')),
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
