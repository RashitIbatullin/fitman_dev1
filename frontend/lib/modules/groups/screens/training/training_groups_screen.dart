import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import './training_group_edit_screen.dart';
import '../../widgets/training/training_group_card.dart';
import '../../models/training_group.model.dart'; // Import for TrainingGroup
import 'package:fitman_app/services/api_service.dart'; // Import ApiService
import 'package:fitman_app/modules/users/models/user.dart'; // Import User
import 'package:fitman_app/widgets/filter_popup_menu.dart';

class TrainingGroupsScreen extends ConsumerStatefulWidget {
  const TrainingGroupsScreen({super.key});

  @override
  ConsumerState<TrainingGroupsScreen> createState() => _TrainingGroupsScreenState();
}

class _TrainingGroupsScreenState extends ConsumerState<TrainingGroupsScreen> {
  String _searchQuery = '';
  int? _selectedGroupTypeId;
  bool? _isActiveFilter = true; // null for 'All', true for 'Active', false for 'Inactive'
  bool? _isArchivedFilter = false; // null for 'All', true for 'Archived', false for 'Not Archived'
  int? _selectedTrainerId;
  int? _selectedInstructorId;
  int? _selectedManagerId;

  List<User> _trainers = [];
  List<User> _instructors = [];
  List<User> _managers = [];

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(usersProvider.notifier).fetchUsers();
      ref.read(trainingGroupTypesProvider);
      await _fetchUsersByRole();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _fetchUsersByRole() async {
    try {
      final allUsers = await ApiService.getUsers();
      if (!mounted) return;
      setState(() {
        _trainers = allUsers.where((user) => user.roles.any((role) => role.name == 'trainer')).toList();
        _instructors = allUsers.where((user) => user.roles.any((role) => role.name == 'instructor')).toList();
        _managers = allUsers.where((user) => user.roles.any((role) => role.name == 'manager')).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки пользователей: $e')),
      );
    }
  }

    @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Widget Builder Functions ---

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Тренировочные группы'),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Поиск по названию',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row of filters (Type, Active/Inactive, Archived/Not Archived)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Crucial for horizontal scrolling
            children: [
              // Existing Group Type Filter
              ...ref.watch(trainingGroupTypesProvider).when(
                data: (types) => [
                  ChoiceChip(
                    label: const Text('Все типы'),
                    selected: _selectedGroupTypeId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGroupTypeId = null;
                      });
                    },
                  ),
                  ...types.map((type) => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(type.title),
                      selected: _selectedGroupTypeId == type.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGroupTypeId = selected ? type.id : null;
                        });
                      },
                    ),
                  )),
                ],
                loading: () => [const SizedBox.shrink()],
                error: (e, st) => [Center(child: Text('Ошибка загрузки типов: $e'))],
              ),
              const SizedBox(width: 16.0), // Spacer

              FilterPopupMenuButton<bool?>(
                tooltip: 'Фильтр по активности',
                initialValue: _isActiveFilter,
                onSelected: (value) {
                  setState(() {
                    _isActiveFilter = value;
                  });
                },
                allOptionText: 'Статус: Все',
                options: [
                  FilterOption(label: 'Активные', value: true),
                  FilterOption(label: 'Неактивные', value: false),
                ],
                avatar: const Icon(Icons.filter_alt),
              ),
              const SizedBox(width: 8.0), // Spacer

              FilterPopupMenuButton<bool?>(
                tooltip: 'Фильтр по архивации',
                initialValue: _isArchivedFilter,
                onSelected: (value) {
                  setState(() {
                    _isArchivedFilter = value;
                  });
                },
                allOptionText: 'Архив: Все',
                options: [
                  FilterOption(label: 'Архивные', value: true),
                  FilterOption(label: 'Неархивные', value: false),
                ],
                avatar: const Icon(Icons.archive),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0), // Space between filter rows

        // Second row of filters (Trainer, Instructor, Manager)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Crucial for horizontal scrolling
            children: [
              // Trainer Filter
              SizedBox(
                width: 180, // Fixed width for the dropdown
                child: IntrinsicWidth( // Added IntrinsicWidth
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey('trainer_filter_dropdown_$_selectedTrainerId'), // Add Key
                    decoration: const InputDecoration(
                      labelText: 'Тренер',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    initialValue: _selectedTrainerId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Все тренеры'),
                      ),
                      ..._trainers.map((user) => DropdownMenuItem<int?>(
                        value: user.id,
                        child: Text(user.fullName),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTrainerId = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // Spacer

              // Instructor Filter
              SizedBox(
                width: 250, // Increased width for the dropdown
                child: IntrinsicWidth( // Added IntrinsicWidth
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey('instructor_filter_dropdown_$_selectedInstructorId'), // Add Key
                    decoration: const InputDecoration(
                      labelText: 'Инструктор',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    initialValue: _selectedInstructorId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Все инструкторы'),
                      ),
                      ..._instructors.map((user) => DropdownMenuItem<int?>(
                        value: user.id,
                        child: Text(user.fullName),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedInstructorId = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // Spacer

              // Manager Filter
              SizedBox(
                width: 220, // Keep increased width for the dropdown
                child: IntrinsicWidth( // Added IntrinsicWidth
                  child: DropdownButtonFormField<int?>(
                    key: ValueKey('manager_filter_dropdown_$_selectedManagerId'), // Add Key
                    decoration: const InputDecoration(
                      labelText: 'Менеджер',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    initialValue: _selectedManagerId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Все менеджеры'),
                      ),
                      ..._managers.map((user) => DropdownMenuItem<int?>(
                        value: user.id,
                        child: Text(user.fullName),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedManagerId = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList(AsyncValue<List<TrainingGroup>> groupsAsyncValue) {
    return Expanded(
      child: groupsAsyncValue.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('Нет групп, соответствующих фильтру.'));
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return TrainingGroupCard(
                  group: group,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TrainingGroupEditScreen(groupId: group.id?.toString()),
                      ),
                    );
                    // Refresh the list after editing
                    ref.invalidate(trainingGroupsProvider(
                      searchQuery: _searchQuery,
                      groupTypeId: _selectedGroupTypeId,
                      isActive: _isActiveFilter,
                      isArchived: _isArchivedFilter,
                      trainerId: _selectedTrainerId,
                      instructorId: _selectedInstructorId,
                      managerId: _selectedManagerId,
                    ));
                  },
                  onDelete: () async {
                    if (group.id == null) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Подтвердите архивацию'),
                        content: Text('Вы уверены, что хотите архивировать группу "${group.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Архивировать'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(trainingGroupsProvider(
                        searchQuery: _searchQuery,
                        groupTypeId: _selectedGroupTypeId,
                        isActive: _isActiveFilter,
                        isArchived: _isArchivedFilter,
                        trainerId: _selectedTrainerId,
                        instructorId: _selectedInstructorId,
                        managerId: _selectedManagerId,
                      ).notifier).deleteTrainingGroup(group.id!);
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: 'training_groups_fab',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TrainingGroupEditScreen(),
          ),
        );
        // Refresh the list after creating
        ref.invalidate(trainingGroupsProvider(
          searchQuery: _searchQuery,
          groupTypeId: _selectedGroupTypeId,
          isActive: _isActiveFilter,
          isArchived: _isArchivedFilter,
          trainerId: _selectedTrainerId,
          instructorId: _selectedInstructorId,
          managerId: _selectedManagerId,
        ));
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainingGroupsAsyncValue = ref.watch(trainingGroupsProvider(
      searchQuery: _searchQuery,
      groupTypeId: _selectedGroupTypeId,
      isActive: _isActiveFilter,
      isArchived: _isArchivedFilter,
      trainerId: _selectedTrainerId,
      instructorId: _selectedInstructorId,
      managerId: _selectedManagerId,
    ));

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(),
          _buildGroupList(trainingGroupsAsyncValue),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}