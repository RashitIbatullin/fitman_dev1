import 'package:fitman_app/modules/supportStaff/providers/support_staff_provider.dart';
import 'package:fitman_app/modules/supportStaff/screens/support_staff_edit_screen.dart';
import 'package:fitman_app/modules/supportStaff/models/employment_type.enum.dart'; // Added import
import 'package:fitman_app/modules/supportStaff/models/staff_category.enum.dart'; // Added import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportStaffDetailScreen extends ConsumerWidget {
  final String staffId;

  const SupportStaffDetailScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(supportStaffByIdProvider(staffId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка сотрудника'),
        actions: [
          staffAsync.when(
            data: (staff) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SupportStaffEditScreen(staff: staff),
                  ),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: staffAsync.when(
        data: (staff) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ФИО:', '${staff.lastName} ${staff.firstName} ${staff.middleName ?? ''}'),
                _buildDetailRow('Телефон:', staff.phone ?? 'Не указан'),
                _buildDetailRow('Email:', staff.email ?? 'Не указан'),
                _buildDetailRow('Тип занятости:', staff.employmentType.localizedName),
                _buildDetailRow('Категория:', staff.category.localizedName),
                _buildDetailRow('Может обслуживать:', staff.canMaintainEquipment ? 'Да' : 'Нет'),
                if (staff.companyName != null)
                  _buildDetailRow('Компания:', staff.companyName!),
                if (staff.contractNumber != null)
                  _buildDetailRow('Номер контракта:', staff.contractNumber!),
                if (staff.contractExpiryDate != null)
                  _buildDetailRow('Окончание контракта:', staff.contractExpiryDate!.toLocal().toString().split(' ')[0]),
                if (staff.notes != null)
                  _buildDetailRow('Заметки:', staff.notes!),

                const SizedBox(height: 20),
                const Text('Компетенции:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                // Placeholder for competencies
                const Text('...'), 
                const SizedBox(height: 20),
                const Text('Расписание:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                // Placeholder for schedule
                const Text('...'),

              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
