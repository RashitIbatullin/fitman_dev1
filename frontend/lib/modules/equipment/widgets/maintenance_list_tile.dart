import 'package:fitman_app/modules/equipment/screens/item/maintenance_details_screen.dart';
import 'package:fitman_common/modules/equipment/equipment_maintenance_history.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fitman_app/extensions/equipment_ui_extensions.dart';

class MaintenanceListTile extends ConsumerWidget {
  const MaintenanceListTile({
    super.key,
    required this.historyItem,
    this.trailing,
    this.statusDetails,
  });

  final EquipmentMaintenanceHistory historyItem;
  final Widget? trailing;
  final Widget? statusDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArchived = historyItem.archivedAt != null;
    final String statusLabel = 'Статус:'; // Declare the variable here

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isArchived ? Colors.grey.shade200 : null,
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MaintenanceDetailsScreen(maintenanceId: historyItem.id!),
            ),
          );
        },
        title: Text(historyItem.reportedProblem),
        subtitle: Wrap(
          spacing: 8.0, // space between items
          runSpacing: 4.0,
          children: [
            // ignore: use_null_aware_elements
            if (historyItem.number case final number?)
              Text('№$number', style: const TextStyle(fontWeight: FontWeight.bold)),
            // Fix for unnecessary_string_interpolations info
            Text(statusLabel, style: TextStyle(color: Colors.black)),
            Text(historyItem.status.title, style: TextStyle(fontWeight: FontWeight.bold, color: historyItem.status.color)),
            // ignore: use_null_aware_elements
            if (historyItem.createdAt case final createdAt?)
              Text('Создано: ${DateFormat('dd.MM.yy').format(createdAt.toLocal())}'),
            // ignore: use_null_aware_elements
            if (statusDetails case final details?) details,
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
