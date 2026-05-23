import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import './training_group_edit_screen.dart';
import '../../widgets/training/training_group_card.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/widgets/filter_popup_menu.dart';

class TrainingGroupsScreen extends ConsumerStatefulWidget {
  const TrainingGroupsScreen({super.key});

  @override
  ConsumerState<TrainingGroupsScreen> createState() =>
      _TrainingGroupsScreenState();
}

class _TrainingGroupsScreenState extends ConsumerState<TrainingGroupsScreen> {
  String _searchQuery = '';
  String? _selectedGroupTypeId;
  bool? _isActiveFilter = true;
  bool? _isArchivedFilter = false;

  // New combined employee filter state
  User? _selectedEmployee;
  String? _selectedEmployeeRole;

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
        _trainers = allUsers
            .where((user) => user.roles.any((role) => role.name == 'trainer'))
            .toList();
        _instructors = allUsers
            .where((user) => user.roles.any((role) => role.name == 'instructor'))
            .toList();
        _managers = allUsers
            .where((user) => user.roles.any((role) => role.name == 'manager'))
            .toList();
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    error: (e, st) =>
                        [Center(child: Text('Ошибка загрузки типов: $e'))],
                  ),
              const SizedBox(width: 16.0),
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
              const SizedBox(width: 8.0),
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
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _EmployeePicker(
            selectedEmployee: _selectedEmployee,
            trainers: _trainers,
            instructors: _instructors,
            managers: _managers,
            onChanged: (user, role) {
              setState(() {
                _selectedEmployee = user;
                _selectedEmployeeRole = role;
              });
            },
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
            return const Center(
                child: Text('Нет групп, соответствующих фильтру.'));
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
                        builder: (context) =>
                            TrainingGroupEditScreen(groupId: group.id?.toString()),
                      ),
                    );
                    ref.invalidate(trainingGroupsProvider);
                  },
                  onDelete: () async {
                    if (group.id == null) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Подтвердите архивацию'),
                        content: Text(
                            'Вы уверены, что хотите архивировать группу "${group.name}"?'),
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
                      await ref
                          .read(trainingGroupsProvider().notifier)
                          .deleteTrainingGroup(group.id!);
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
        ref.invalidate(trainingGroupsProvider);
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? trainerId = (_selectedEmployeeRole == 'trainer') ? _selectedEmployee?.id : null;
    final String? instructorId = (_selectedEmployeeRole == 'instructor') ? _selectedEmployee?.id : null;
    final String? managerId = (_selectedEmployeeRole == 'manager') ? _selectedEmployee?.id : null;

    final trainingGroupsAsyncValue = ref.watch(trainingGroupsProvider(
      searchQuery: _searchQuery,
      groupTypeId: _selectedGroupTypeId,
      isActive: _isActiveFilter,
      isArchived: _isArchivedFilter,
      trainerId: trainerId,
      instructorId: instructorId,
      managerId: managerId,
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

class _EmployeePicker extends StatelessWidget {
  final User? selectedEmployee;
  final List<User> trainers;
  final List<User> instructors;
  final List<User> managers;
  final Function(User?, String?) onChanged;

  const _EmployeePicker({
    required this.selectedEmployee,
    required this.trainers,
    required this.instructors,
    required this.managers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => _EmployeePickerSheet(
            trainers: trainers,
            instructors: instructors,
            managers: managers,
            onChanged: onChanged,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_search, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedEmployee?.fullName ?? 'Все сотрудники',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeSearchResult {
  final User user;
  final String role;
  _EmployeeSearchResult(this.user, this.role);
}

class _EmployeePickerSheet extends StatefulWidget {
  final List<User> trainers;
  final List<User> instructors;
  final List<User> managers;
  final Function(User?, String?) onChanged;

  const _EmployeePickerSheet({
    required this.trainers,
    required this.instructors,
    required this.managers,
    required this.onChanged,
  });

  @override
  State<_EmployeePickerSheet> createState() => _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends State<_EmployeePickerSheet> {
  String _searchQuery = '';

  String _roleDisplayName(String role) {
    switch (role) {
      case 'trainer':
        return 'Тренер';
      case 'instructor':
        return 'Инструктор';
      case 'manager':
        return 'Менеджер';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSearch = _searchQuery.isNotEmpty;

    List<_EmployeeSearchResult> searchResults = [];
    if (hasSearch) {
      final filteredTrainers = widget.trainers
          .where((u) =>
              u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()));
      searchResults.addAll(filteredTrainers
          .map((u) => _EmployeeSearchResult(u, 'trainer')));

      final filteredInstructors = widget.instructors
          .where((u) =>
              u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()));
      searchResults.addAll(filteredInstructors
          .map((u) => _EmployeeSearchResult(u, 'instructor')));

      final filteredManagers = widget.managers
          .where((u) =>
              u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()));
       searchResults.addAll(filteredManagers
          .map((u) => _EmployeeSearchResult(u, 'manager')));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Поиск по сотруднику',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: hasSearch
                ? (searchResults.isEmpty 
                    ? const Center(child: Text('Сотрудники не найдены.'))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final result = searchResults[index];
                          return ListTile(
                            title: Text(result.user.fullName),
                            subtitle: Text(_roleDisplayName(result.role)),
                            onTap: () {
                              widget.onChanged(result.user, result.role);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ))
                : ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.clear_all),
                        title: const Text('Все сотрудники',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          widget.onChanged(null, null);
                          Navigator.pop(context);
                        },
                      ),
                      if (widget.trainers.isNotEmpty)
                        ExpansionTile(
                          leading: const Icon(Icons.sports_martial_arts),
                          title: const Text('Тренеры',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          children: widget.trainers.map((user) {
                            return ListTile(
                              title: Text(user.fullName),
                              onTap: () {
                                widget.onChanged(user, 'trainer');
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      if (widget.instructors.isNotEmpty)
                        ExpansionTile(
                          leading: const Icon(Icons.fitness_center),
                          title: const Text('Инструкторы',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          children: widget.instructors.map((user) {
                            return ListTile(
                              title: Text(user.fullName),
                              onTap: () {
                                widget.onChanged(user, 'instructor');
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      if (widget.managers.isNotEmpty)
                        ExpansionTile(
                          leading: const Icon(Icons.manage_accounts),
                          title: const Text('Менеджеры',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          children: widget.managers.map((user) {
                            return ListTile(
                              title: Text(user.fullName),
                              onTap: () {
                                widget.onChanged(user, 'manager');
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
