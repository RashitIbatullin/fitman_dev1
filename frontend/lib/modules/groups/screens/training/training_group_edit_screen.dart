import 'dart:async';
import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import '../../widgets/common/group_member_list.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:intl/intl.dart';

class TrainingGroupEditScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const TrainingGroupEditScreen({super.key, this.groupId});

  @override
  ConsumerState<TrainingGroupEditScreen> createState() =>
      _TrainingGroupEditScreenState();
}

class _TrainingGroupEditScreenState
    extends ConsumerState<TrainingGroupEditScreen> {
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
  List<User> _allUsers = [];
  List<User> _trainers = [];
  List<User> _instructors = [];
  List<User> _managers = [];

  // New state for managing members locally
  List<User> _members = [];
  final List<String> _membersToAdd = [];
  final List<String> _membersToRemove = [];

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
    await _fetchUsers();
    if (_groupId != null) {
      await _loadGroupData();
    } else {
      _maxParticipantsController.text = '15';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchUsers() async {
    try {
      // Fetch users if the list is empty
      if (ref.read(usersProvider).users.isEmpty) {
        await ref.read(usersProvider.notifier).fetchUsers();
      }
      if (!mounted) return;
      _allUsers = ref.read(usersProvider).users;
      _trainers =
          _allUsers.where((u) => u.roles.any((r) => r.name == 'trainer')).toList();
      _instructors = _allUsers
          .where((u) => u.roles.any((r) => r.name == 'instructor'))
          .toList();
      _managers =
          _allUsers.where((u) => u.roles.any((r) => r.name == 'manager')).toList();
    } catch (e) {
      print('Failed to fetch users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
    }
  }

  Future<void> _loadGroupData() async {
    try {
      final group = await ApiService.getTrainingGroupById(_groupId!);
      if (!mounted) return;

      final memberIds = await ref.read(groupMembersProvider(_groupId).future);
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

      // Populate local members list
      _members =
          _allUsers.where((user) => memberIds.contains(user.id)).toList();
    } catch (e) {
      print('Failed to load group data: $e');
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
  void _handleSaveSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Группа успешно сохранена!')),
    );
    Navigator.of(context).pop(true); // Pop with success
  }

  void _handleSaveError(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка сохранения группы: $e')),
    );
  }
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      TrainingGroup groupToSave;
      if (_groupId == null) {
        // Create new group
        final newGroup = TrainingGroup(
          id: null,
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          trainingGroupTypeId: _selectedGroupTypeId!,
          primaryTrainerId: _selectedPrimaryTrainerId,
          primaryInstructorId: _selectedPrimaryInstructorId,
          responsibleManagerId: _selectedResponsibleManagerId,
          maxParticipants: int.parse(_maxParticipantsController.text),
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
          chatId: _chatId,
          clientIds: const [], // Will be handled separately
        );
        groupToSave = await ref
            .read(trainingGroupsProvider().notifier)
            .createTrainingGroup(newGroup);
      } else {
        // Update existing group
        final updatedGroup = _initialGroup!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          trainingGroupTypeId: _selectedGroupTypeId!,
          primaryTrainerId: _selectedPrimaryTrainerId,
          primaryInstructorId: _selectedPrimaryInstructorId,
          responsibleManagerId: _selectedResponsibleManagerId,
          maxParticipants: int.parse(_maxParticipantsController.text),
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
        );
        groupToSave = await ref
            .read(trainingGroupsProvider().notifier)
            .updateTrainingGroup(updatedGroup);
      }

      // After saving the group, update members
      final memberNotifier = ref.read(groupMembersProvider(groupToSave.id!).notifier);
      await Future.wait([
        ..._membersToAdd.map((userId) => memberNotifier.addMember(groupToSave.id!, userId)),
        ..._membersToRemove.map((userId) => memberNotifier.removeMember(groupToSave.id!, userId)),
      ]);


      if (!mounted) return;
      _handleSaveSuccess();
    } catch (e) {
      if (!mounted) return;
      _handleSaveError(e);
    } finally {
      if(context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleRemoveMember(String userId) {
    print('[DEBUG] _handleRemoveMember called with userId: $userId');
    setState(() {
      _members.removeWhere((user) => user.id == userId);
      if (_membersToAdd.contains(userId)) {
        _membersToAdd.remove(userId);
      } else if (!_membersToRemove.contains(userId)){
        _membersToRemove.add(userId);
      }
    });
  }

  void _handleMoveMember(String memberId) {
    final member = _members.firstWhere((m) => m.id == memberId);
    _showMoveMemberDialog(member);
  }

  Future<void> _showMoveMemberDialog(User member) async {
    final allGroups = await ref.read(trainingGroupsProvider().future);
    
    if (!context.mounted) return;

    final otherGroups = allGroups.where((g) => g.id != _groupId).toList();
    
    String? destinationGroupId;
    final reasonController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Переместить ${member.fullName}'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'В группу'),
                  items: otherGroups.map((group) {
                    return DropdownMenuItem(
                      value: group.id,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    destinationGroupId = value;
                  },
                  validator: (value) => value == null ? 'Выберите группу' : null,
                ),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Причина перемещения'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Укажите причину';
                    }
                    if (value.length < 5) {
                      return 'Причина должна быть не менее 5 символов';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Переместить'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && destinationGroupId != null) {
      setState(() => _isLoading = true);
      
      final logData = {
        'clientId': member.id,
        'fromGroupId': _groupId,
        'toGroupId': destinationGroupId,
        'reason': reasonController.text,
      };
      print('[MOVE CLIENT] Attempting to move client with data: $logData');

      try {
        await ApiService.moveClient(
              clientId: member.id,
              fromGroupId: _groupId!,
              toGroupId: destinationGroupId!,
              reason: reasonController.text,
            );
        
        print('[MOVE CLIENT] API call successful.');
        setState(() {
          _members.removeWhere((m) => m.id == member.id);
        });


        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Клиент успешно перемещен.')),
        );
      } catch (e) {
        print('[MOVE CLIENT] Error during move client: $e');


        String errorMessage = 'Произошла неизвестная ошибка.';
        final eString = e.toString().toLowerCase();

        if (eString.contains('target group is already full')) {
          errorMessage = 'Целевая группа уже заполнена.';
        } else if (eString.contains('target group not found')) {
          errorMessage = 'Целевая группа не найдена.';
        } else {
          errorMessage = 'Ошибка перемещения: $e';
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if(mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showAddMemberDialog() {
    final currentMemberIds = _members.map((u) => u.id).toList();
    final availableClients = _allUsers.where((user) {
      return user.roles.any((role) => role.name == 'client') &&
          !currentMemberIds.contains(user.id);
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            final filteredClients = availableClients.where((user) {
              final query = searchQuery.toLowerCase();
              return user.fullName.toLowerCase().contains(query) ||
                  (user.phone?.contains(query) ?? false);
            }).toList();

            return AlertDialog(
              title: const Text('Добавить клиента'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setStateDialog(() {
                          searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Поиск по ФИО или телефону',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredClients.isEmpty
                          ? const Text('Клиенты не найдены.')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredClients.length,
                              itemBuilder: (context, index) {
                                final user = filteredClients[index];
                                return ListTile(
                                  title: Text(user.fullName),
                                  subtitle:
                                      Text(user.phone ?? 'Нет телефона'),
                                  onTap: () {
                                    setState(() {
                                      _members.add(user);
                                      if (_membersToRemove.contains(user.id)) {
                                        _membersToRemove.remove(user.id);
                                      } else if (!_membersToAdd.contains(user.id)) {
                                        _membersToAdd.add(user.id);
                                      }
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
     final isEditing = _groupId != null;

     return DefaultTabController(
      length: isEditing ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Редактировать группу' : 'Создать группу'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveForm,
            ),
          ],
          bottom: isEditing
              ? const TabBar(
                  tabs: [
                    Tab(text: 'Основное'),
                    Tab(text: 'Перемещения'),
                  ],
                )
              : null,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
              children: [
                SingleChildScrollView(
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
                        Text('Члены группы', style: Theme.of(context).textTheme.titleMedium),
                        
                        GroupMemberList(
                          members: _members,
                          onAdd: _showAddMemberDialog,
                          onRemove: _handleRemoveMember,
                          onMove: _handleMoveMember,
                        ),

                        const Divider(),
                        Text('Расписание группы',
                            style: Theme.of(context).textTheme.titleMedium),
                        if (_groupId != null) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                                'Расписание можно настроить после создания группы.'),
                          ),
                        ] else ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                                'Расписание можно настроить после создания группы.'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isEditing)
                  _MovementHistoryView(groupId: _groupId),
              ],
            ),
      ),
    );
  }
}

class _MovementHistoryView extends ConsumerWidget {
  final String groupId;

  const _MovementHistoryView({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(groupMovementsProvider(groupId));
    final allUsers = ref.watch(usersProvider).users;
    // Also watch all groups to resolve names
    final allGroupsAsync = ref.watch(trainingGroupsProvider());

    String getUserName(String userId) {
      final user = allUsers.firstWhere((u) => u.id == userId, orElse: () => User.fromJson({'id': userId, 'first_name': 'Неизвестный', 'last_name': 'Пользователь'}));
      return user.fullName;
    }

    return allGroupsAsync.when(
      data: (allGroups) {
        String getGroupName(String? groupId) {
          if (groupId == null) return 'N/A';
          final group = allGroups.firstWhere((g) => g.id == groupId, orElse: () => TrainingGroup(id: groupId, name: 'Неизвестная группа', trainingGroupTypeId: '', maxParticipants: 0, startDate: DateTime.now()));
          return group.name;
        }

        return movementsAsync.when(
          data: (movements) {
            if (movements.isEmpty) {
              return const Center(child: Text('История перемещений пуста.'));
            }
            return ListView.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];
                final movedUser = getUserName(movement.userId);
                final movedBy = getUserName(movement.movedByUserId);
                
                String title = movedUser;
                String subtitle = '';

                if (movement.fromGroupId != null && movement.toGroupId != null) {
                  title += ' перемещен';
                  subtitle = 'Из: ${getGroupName(movement.fromGroupId)}\nВ: ${getGroupName(movement.toGroupId)}';
                } else if (movement.toGroupId != null) {
                  title += ' добавлен в группу';
                  subtitle = 'В: ${getGroupName(movement.toGroupId)}';
                } else {
                  title += ' удален из группы';
                  subtitle = 'Из: ${getGroupName(movement.fromGroupId)}';
                }
                subtitle += '\nДата: ${DateFormat('dd.MM.yyyy HH:mm').format(movement.movementDate.toLocal())}';
                if (movement.reason != null && movement.reason!.isNotEmpty) {
                  subtitle += '\nПричина: ${movement.reason}';
                }
                subtitle += '\nИнициатор: $movedBy';


                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(subtitle),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Ошибка загрузки истории: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки групп: $error')),
    );
  }
}
