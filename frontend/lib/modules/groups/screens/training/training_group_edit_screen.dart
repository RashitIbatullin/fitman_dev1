import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import '../../widgets/common/group_member_list.dart'; // For later use
import 'package:fitman_app/services/api_service.dart'; // For fetching users for dropdowns
import 'package:fitman_common/fitman_common.dart'; // For user dropdown
import 'package:intl/intl.dart'; // New import

class TrainingGroupEditScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const TrainingGroupEditScreen({super.key, this.groupId});

  @override
  ConsumerState<TrainingGroupEditScreen> createState() => _TrainingGroupEditScreenState();
}

class _TrainingGroupEditScreenState extends ConsumerState<TrainingGroupEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final String? _groupId;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedGroupTypeId;
  String? _selectedPrimaryTrainerId;
  String? _selectedPrimaryInstructorId;
  String? _selectedResponsibleManagerId;
  late TextEditingController _maxParticipantsController;

  late DateTime _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  String? _chatId;

  bool _isLoading = true;
  TrainingGroup? _initialGroup;
  List<User> _trainers = [];
  List<User> _instructors = [];
  List<User> _managers = [];

  @override
  void initState() {
    super.initState();
    _groupId = widget.groupId;
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _maxParticipantsController = TextEditingController();

    _startDate = DateTime.now();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    // Fetch users first
    await _fetchUsers();
    // If it's an existing group, load its data
    if (_groupId != null) {
      await _loadGroupData();
    } else {
      // Set defaults for a new group
      _maxParticipantsController.text = '15';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await ApiService.getUsers();
      if (!mounted) return;
      _trainers = users.where((u) => u.roles.any((r) => r.name == 'trainer')).toList();
      _instructors = users.where((u) => u.roles.any((r) => r.name == 'instructor')).toList();
      _managers = users.where((u) => u.roles.any((r) => r.name == 'manager')).toList();
    } catch (e) {
      print('Failed to fetch users: $e');
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
    }
  }

  Future<void> _loadGroupData() async {
    try {
      final group = await ApiService.getTrainingGroupById(_groupId!);
      if (!mounted) return;
      _initialGroup = group;
      _nameController.text = group.name;
      _descriptionController.text = group.description ?? '';
      _selectedGroupTypeId = group.trainingGroupTypeId;
      _selectedPrimaryTrainerId = group.primaryTrainerId;
      _selectedPrimaryInstructorId = group.primaryInstructorId;
      _selectedResponsibleManagerId = group.responsibleManagerId;
      _maxParticipantsController.text = group.maxParticipants.toString();

      _startDate = group.startDate;
      _endDate = group.endDate;
      _isActive = group.isActive ?? true;
      _chatId = group.chatId;
    }
    catch (e) {
      print('Failed to load group data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();

    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGroup = TrainingGroup(
        id: _groupId,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        trainingGroupTypeId: _selectedGroupTypeId!,
        primaryTrainerId: _selectedPrimaryTrainerId,
        primaryInstructorId: _selectedPrimaryInstructorId,
        responsibleManagerId: _selectedResponsibleManagerId,
        maxParticipants: int.parse(_maxParticipantsController.text),

        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        chatId: _chatId,
        clientIds: _initialGroup?.clientIds ?? [], // ClientIds are managed separately
      );

      try {
        if (_groupId == null) {
          // Create new group
          await ref.read(trainingGroupsProvider(searchQuery: '', groupTypeId: null, isActive: null, isArchived: null, trainerId: null, instructorId: null, managerId: null).notifier).createTrainingGroup(newGroup);
        } else {
          // Update existing group
          await ref.read(trainingGroupsProvider(searchQuery: '', groupTypeId: null, isActive: null, isArchived: null, trainerId: null, instructorId: null, managerId: null).notifier).updateTrainingGroup(newGroup);
        }
        if (!mounted) return; // Add check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа успешно сохранена!')),
        );
        if (!mounted) return; // Add check
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return; // Add check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения группы: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupId == null ? 'Создать тренировочную группу' : 'Редактировать тренировочную группу'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(labelText: 'Название группы *', labelStyle: Theme.of(context).textTheme.labelMedium),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(labelText: 'Описание', labelStyle: Theme.of(context).textTheme.labelMedium),
                maxLines: 1,
              ),
              ref.watch(trainingGroupTypesProvider).when(
                data: (types) => DropdownButtonFormField<String>(
                  initialValue: _selectedGroupTypeId,
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: InputDecoration(labelText: 'Тип группы', labelStyle: Theme.of(context).textTheme.labelMedium),
                  items: types.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.title, style: Theme.of(context).textTheme.bodySmall),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGroupTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите тип группы';
                    }
                    return null;
                  },
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => Center(child: Text('Ошибка: $err')),
              ),
              DropdownButtonFormField<String?>(
                initialValue: _selectedPrimaryTrainerId,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(labelText: 'Основной тренер', labelStyle: Theme.of(context).textTheme.labelMedium),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Не назначен', style: Theme.of(context).textTheme.bodySmall),
                  ),
                  ..._trainers.map((user) {
                    return DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text(user.fullName, style: Theme.of(context).textTheme.bodySmall),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPrimaryTrainerId = value;
                  });
                },
              ),
              DropdownButtonFormField<String?>(
                initialValue: _selectedPrimaryInstructorId,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(labelText: 'Основной инструктор (опционально)', labelStyle: Theme.of(context).textTheme.labelMedium),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text('Нет', style: Theme.of(context).textTheme.bodySmall)),
                  ..._instructors.map((user) {
                    return DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text(user.fullName, style: Theme.of(context).textTheme.bodySmall),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPrimaryInstructorId = value;
                  });
                },
              ),
              DropdownButtonFormField<String?>(
                initialValue: _selectedResponsibleManagerId,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(labelText: 'Ответственный менеджер (опционально)', labelStyle: Theme.of(context).textTheme.labelMedium),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text('Нет', style: Theme.of(context).textTheme.bodySmall)),
                  ..._managers.map((user) {
                    return DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text(user.fullName, style: Theme.of(context).textTheme.bodySmall),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedResponsibleManagerId = value;
                  });
                },
              ),
              TextFormField(
                controller: _maxParticipantsController,
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(labelText: 'Макс. участников', labelStyle: Theme.of(context).textTheme.labelMedium),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Пожалуйста, введите число';
                  }
                  return null;
                },
              ),
              // Current participants are now calculated automatically
              ListTile(
                title: Text('Дата начала: ${DateFormat('dd.MM.yyyy').format(_startDate)}', style: Theme.of(context).textTheme.bodySmall),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Дата окончания: ${_endDate != null ? DateFormat('dd.MM.yyyy').format(_endDate!) : 'Не указана'}', style: Theme.of(context).textTheme.bodySmall),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
                    firstDate: _startDate,
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDate = pickedDate;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: Text('Активна', style: Theme.of(context).textTheme.bodySmall),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const Divider(),
              Text('Члены группы', style: Theme.of(context).textTheme.titleSmall),
              if (_groupId != null) ...[
                GroupMemberList(groupId: _groupId),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Членов можно добавить после создания группы.', style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
              const Divider(),
              Text('Расписание группы', style: Theme.of(context).textTheme.titleSmall),
              if (_groupId != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Расписание можно настроить после создания группы.'),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Расписание можно настроить после создания группы.', style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}