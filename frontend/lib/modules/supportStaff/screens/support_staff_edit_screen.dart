import 'package:fitman_app/modules/supportStaff/models/competency.model.dart';
import 'package:fitman_app/modules/supportStaff/models/employment_type.enum.dart';
import 'package:fitman_app/modules/supportStaff/models/staff_category.enum.dart';
import 'package:fitman_app/modules/supportStaff/models/support_staff.model.dart';
import 'package:fitman_app/modules/supportStaff/providers/support_staff_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportStaffEditScreen extends ConsumerStatefulWidget {
  final SupportStaff? staff;

  const SupportStaffEditScreen({super.key, this.staff});

  @override
  ConsumerState<SupportStaffEditScreen> createState() =>
      _SupportStaffEditScreenState();
}

class _SupportStaffEditScreenState
    extends ConsumerState<SupportStaffEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyNameController;
  late TextEditingController _contractNumberController;
  late TextEditingController _notesController;

  late EmploymentType _employmentType;
  late StaffCategory _staffCategory;
  late bool _canMaintainEquipment;
  DateTime? _contractExpiryDate;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.staff?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.staff?.lastName ?? '');
    _middleNameController =
        TextEditingController(text: widget.staff?.middleName ?? '');
    _phoneController = TextEditingController(text: widget.staff?.phone ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _companyNameController =
        TextEditingController(text: widget.staff?.companyName ?? '');
    _contractNumberController =
        TextEditingController(text: widget.staff?.contractNumber ?? '');
    _notesController = TextEditingController(text: widget.staff?.notes ?? '');

    _employmentType =
        widget.staff?.employmentType ?? EmploymentType.fullTime;
    _staffCategory = widget.staff?.category ?? StaffCategory.technician;
    _canMaintainEquipment = widget.staff?.canMaintainEquipment ?? false;
    _contractExpiryDate = widget.staff?.contractExpiryDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _contractNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final staffToSave = (widget.staff ??
              SupportStaff(
                id: '', // Will be ignored by backend on create
                firstName: '',
                lastName: '',
                employmentType: EmploymentType.fullTime,
                category: StaffCategory.technician,
                canMaintainEquipment: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        middleName: _middleNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        employmentType: _employmentType,
        category: _staffCategory,
        canMaintainEquipment: _canMaintainEquipment,
        companyName: _companyNameController.text,
        contractNumber: _contractNumberController.text,
        contractExpiryDate: _contractExpiryDate,
        notes: _notesController.text,
      );

      try {
        if (widget.staff == null) {
          await ApiService.createSupportStaff(staffToSave);
        } else {
          await ApiService.updateSupportStaff(widget.staff!.id, staffToSave);
        }
        ref.invalidate(allSupportStaffProvider);
        if (widget.staff != null) {
          ref.invalidate(supportStaffByIdProvider(widget.staff!.id));
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // Handle error
      }
    }
  }

  void _showAddCompetencyDialog() {
    final nameController = TextEditingController();
    final levelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить компетенцию'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                  validator: (value) =>
                      value!.isEmpty ? 'Введите название' : null,
                ),
                TextFormField(
                  controller: levelController,
                  decoration: const InputDecoration(labelText: 'Уровень (1-5)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите уровень';
                    }
                    final level = int.tryParse(value);
                    if (level == null || level < 1 || level > 5) {
                      return 'Уровень должен быть от 1 до 5';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newCompetency = Competency(
                    id: '', // Backend handles ID
                    name: nameController.text,
                    level: int.parse(levelController.text), staffId: '',
                  );
                  ref.read(supportStaffNotifierProvider.notifier).addCompetency(
                        widget.staff!.id,
                        newCompetency,
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we are editing, we watch the provider to get live updates
    final staffAsyncValue = widget.staff != null
        ? ref.watch(supportStaffByIdProvider(widget.staff!.id))
        : null;

    if (staffAsyncValue is AsyncLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (staffAsyncValue is AsyncError) {
      return Scaffold(
          body: Center(
              child: Text('Error: ${staffAsyncValue?.error ?? "Unknown error"}')));
    }

    // Use the fetched staff data if available, otherwise use the initial widget data
    final currentStaff = staffAsyncValue?.value ?? widget.staff;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'Новый сотрудник' : 'Редактировать'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) =>
                    value!.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
                validator: (value) =>
                    value!.isEmpty ? 'Введите фамилию' : null,
              ),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Отчество'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<EmploymentType>(
                initialValue: _employmentType,
                decoration: const InputDecoration(labelText: 'Тип занятости'),
                items: EmploymentType.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Icon(e.iconData),
                              const SizedBox(width: 8),
                              Text(e.localizedName),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _employmentType = value);
                  }
                },
              ),
              DropdownButtonFormField<StaffCategory>(
                initialValue: _staffCategory,
                decoration: const InputDecoration(labelText: 'Категория'),
                items: StaffCategory.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              Icon(e.iconData),
                              const SizedBox(width: 8),
                              Text(e.localizedName),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _staffCategory = value);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Может обслуживать оборудование'),
                value: _canMaintainEquipment,
                onChanged: (value) =>
                    setState(() => _canMaintainEquipment = value),
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Компания'),
              ),
              TextFormField(
                controller: _contractNumberController,
                decoration: const InputDecoration(labelText: 'Номер контракта'),
              ),
              ListTile(
                title: Text(
                    'Окончание контракта: ${currentStaff?.contractExpiryDate?.toLocal().toString().split(' ')[0] ?? ''}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: currentStaff?.contractExpiryDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (date != null) {
                    setState(() {
                      _contractExpiryDate = date;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Заметки'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              if (currentStaff != null)
                _CompetenciesSection(
                    staff: currentStaff,
                    onAdd: _showAddCompetencyDialog,
                    onDelete: (competencyId) {
                      ref
                          .read(supportStaffNotifierProvider.notifier)
                          .deleteCompetency(currentStaff.id, competencyId);
                    }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Сохранить'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetenciesSection extends StatelessWidget {
  final SupportStaff staff;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  const _CompetenciesSection(
      {required this.staff, required this.onAdd, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final competencies = staff.competencies ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Компетенции',
            style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        if (competencies.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('Компетенции не добавлены')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: competencies.length,
            itemBuilder: (context, index) {
              final competency = competencies[index];
              return ListTile(
                title: Text(competency.name),
                subtitle: Text('Уровень: ${competency.level}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(competency.id),
                ),
              );
            },
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Добавить'),
          ),
        ),
      ],
    );
  }
}
