import 'dart:async';
import 'package:fitman_app/modules/users/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import 'package:fitman_common/modules/groups/training_group.model.dart';
import 'replacement_history_view.dart';
import 'removal_history_view.dart';
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

  Future<void> _showSelectUserDialog({
    required String title,
    required List<User> users,
    required Function(String) onSelected,
  }) async {
    return showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            final filteredUsers = users.where((user) {
              final query = searchQuery.toLowerCase();
              return user.fullName.toLowerCase().contains(query) ||
                  (user.phone?.contains(query) ?? false);
            }).toList();

            return AlertDialog(
              title: Text(title),
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
                        labelText: 'Поиск...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return ListTile(
                            title: Text(user.fullName),
                            onTap: () {
                              onSelected(user.id);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showReplaceStaffDialog({
    required String roleTitle,
    required List<User> availableUsers,
    required Function(String, String) onConfirm,
  }) async {
    String? selectedUserId;
    final reasonController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Заменить $roleTitle'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Новый сотрудник'),
                  items: availableUsers.map((user) {
                    return DropdownMenuItem(
                      value: user.id,
                      child: Text(user.fullName),
                    );
                  }).toList(),
                  onChanged: (value) => selectedUserId = value,
                  validator: (value) => value == null ? 'Выберите сотрудника' : null,
                ),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Причина замены'),
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return 'Причина не менее 5 символов';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) Navigator.of(context).pop(true);
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && selectedUserId != null) {
      onConfirm(selectedUserId!, reasonController.text);
    }
  }

  Future<void> _showRemoveStaffDialog({
    required String roleTitle,
    required String? staffId,
    required Function(String) onConfirm,
  }) async {
    final reasonController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    
    final staffName = staffId != null 
        ? _allUsers.firstWhere((u) => u.id == staffId, orElse: () => User.fromJson({'id': staffId, 'first_name': 'Неизвестный', 'last_name': 'Сотрудник'})).fullName 
        : 'сотрудника';

    String roleName = 'сотрудника';
    if (roleTitle.contains('тренер')) {
      roleName = 'тренера';
    } else if (roleTitle.contains('инструктор')) {
      roleName = 'инструктора';
    } else if (roleTitle.contains('менеджер')) {
      roleName = 'менеджера';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Удалить $roleName?'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Удалить '$staffName' из группы?"),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Причина удаления'),
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return 'Причина не менее 5 символов';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) Navigator.of(context).pop(true);
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onConfirm(reasonController.text);
    }
  }

  Widget _buildUserSelectionTile({
    required String title,
    required String? selectedUserId,
    required List<User> availableUsers,
    required Function(String?) onUserChanged,
  }) {
    final selectedUser = selectedUserId != null
        ? _allUsers.firstWhere((u) => u.id == selectedUserId)
        : null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(selectedUser?.fullName ?? 'Не назначен',
          style: Theme.of(context).textTheme.bodySmall),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'add') {
            _showSelectUserDialog(
              title: 'Выбрать ${title.toLowerCase()}',
              users: availableUsers,
              onSelected: onUserChanged,
            );
          } else if (value == 'move') {
            _showReplaceStaffDialog(
              roleTitle: title.toLowerCase(),
              availableUsers: availableUsers.where((u) => u.id != selectedUserId).toList(),
              onConfirm: (userId, reason) async {
                if (_groupId != null && selectedUserId != null) {
                  try {
                    String role = '';
                    if (title.contains('тренер')) {
                      role = 'trainer';
                    } else if (title.contains('инструктор')) {
                      role = 'instructor';
                    } else if (title.contains('менеджер')) {
                      role = 'manager';
                    }
                    
                    await ApiService.replaceStaff(
                      groupId: _groupId,
                      oldStaffId: selectedUserId,
                      newStaffId: userId,
                      role: role,
                      reason: reason,
                    );
                    if (!mounted) return;
                    ref.invalidate(groupReplacementsProvider(_groupId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сотрудник успешно заменен')),
                    );
                    onUserChanged(userId);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка при замене сотрудника: $e')),
                    );
                  }
                }
              },
            );
          } else if (value == 'remove') {
            _showRemoveStaffDialog(
              roleTitle: title.toLowerCase(),
              staffId: selectedUserId,
              onConfirm: (reason) async {
                if (_groupId != null && selectedUserId != null) {
                  try {
                    String role = '';
                    if (title.contains('тренер')) {
                      role = 'trainer';
                    } else if (title.contains('инструктор')) {
                      role = 'instructor';
                    } else if (title.contains('менеджер')) {
                      role = 'manager';
                    }
                    
                    await ApiService.removeStaff(
                      groupId: _groupId,
                      staffId: selectedUserId,
                      role: role,
                      reason: reason,
                    );
                    if (!mounted) return;
                    ref.invalidate(groupRemovalsProvider(_groupId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сотрудник успешно удален')),
                    );
                    onUserChanged(null);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка при удалении сотрудника: $e')),
                    );
                  }
                }
              },
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'add', child: Text('Добавить')),
          if (selectedUserId != null) ...[
            const PopupMenuItem(value: 'move', child: Text('Заменить')),
            const PopupMenuItem(value: 'remove', child: Text('Удалить')),
          ],
        ],
      ),
    );
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
          primaryTrainerId: _selectedPrimaryTrainerId, // Pass null if it was cleared
          primaryInstructorId: _selectedPrimaryInstructorId, // Pass null if it was cleared
          responsibleManagerId: _selectedResponsibleManagerId, // Pass null if it was cleared
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

  Future<void> _handleRemoveMember(String userId, String reason) async {
    print('[DEBUG] _handleRemoveMember called with userId: $userId, reason: $reason');
    
    // Call API to log removal
    try {
      await ApiService.moveClient(
        clientId: userId,
        fromGroupId: _groupId!,
        toGroupId: null, // Indicates removal
        reason: reason,
      );
      if (!mounted) return;
      ref.invalidate(groupRemovalsProvider(_groupId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Клиент успешно удален из группы')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении клиента: $e')),
      );
      return; // Do not update local state if API fails
    }

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

    final dialogContext = context;
    final confirmed = await showDialog<bool>(
      context: dialogContext,
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
      if (!mounted) return;
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

        if (!mounted) return;
        ref.invalidate(groupMovementsProvider(_groupId));
        setState(() {
          _members.removeWhere((m) => m.id == member.id);
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Клиент успешно перемещен.')),
        );
      } catch (e) {
        print('[MOVE CLIENT] Error during move client: $e');

        if (!mounted) return;
        String errorMessage = 'Произошла неизвестная ошибка.';
        final eString = e.toString().toLowerCase();

        if (eString.contains('target group is already full')) {
          errorMessage = 'Целевая группа уже заполнена.';
        } else if (eString.contains('target group not found')) {
          errorMessage = 'Целевая группа не найдена.';
        } else {
          errorMessage = 'Ошибка перемещения: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        if (mounted) {
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
      length: isEditing ? 4 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing
                ? 'Редактировать группу: ${_nameController.text}'
                : 'Создать группу',
          ),
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
                    Tab(text: 'Замены'),
                    Tab(text: 'Удаления'),
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
                          style: Theme.of(context).textTheme.bodyMedium,
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
                        _buildUserSelectionTile(
                          title: 'Основной тренер',
                          selectedUserId: _selectedPrimaryTrainerId,
                          availableUsers: _trainers,
                          onUserChanged: (value) => setState(() {
                            _selectedPrimaryTrainerId = value;
                            _initialGroup =
                                _initialGroup?.copyWith(primaryTrainerId: value);
                          }),
                        ),
                        _buildUserSelectionTile(
                          title: 'Основной инструктор (опционально)',
                          selectedUserId: _selectedPrimaryInstructorId,
                          availableUsers: _instructors,
                          onUserChanged: (value) => setState(() {
                            _selectedPrimaryInstructorId = value;
                            _initialGroup = _initialGroup
                                ?.copyWith(primaryInstructorId: value);
                          }),
                        ),
                        _buildUserSelectionTile(
                          title: 'Ответственный менеджер (опционально)',
                          selectedUserId: _selectedResponsibleManagerId,
                          availableUsers: _managers,
                          onUserChanged: (value) => setState(() {
                            _selectedResponsibleManagerId = value;
                            _initialGroup = _initialGroup
                                ?.copyWith(responsibleManagerId: value);
                          }),
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
                          onAdd: () => _showAddMemberDialog(),
                          onRemove: (userId, reason) => _handleRemoveMember(userId, reason),
                          onMove: (userId) => _handleMoveMember(userId),
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
                if (isEditing) ...[
                  _MovementHistoryView(groupId: _groupId),
                  ReplacementHistoryView(groupId: _groupId),
                  RemovalHistoryView(groupId: _groupId),
                ],
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

                final String title;
                final String subtitle;

                if (movement.fromGroupId != null && movement.toGroupId != null) {
                  title = 'Клиент: $movedUser перемещен';
                  subtitle = 'Из: ${getGroupName(movement.fromGroupId)}\nВ: ${getGroupName(movement.toGroupId)}'
                             '\nДата: ${DateFormat('dd.MM.yyyy HH:mm').format(movement.movementDate.toLocal())}'
                             '${(movement.reason != null && movement.reason!.isNotEmpty) ? '\nПричина: ${movement.reason}' : ''}'
                             '\nИнициатор: $movedBy';
                } else {
                  title = 'Клиент: $movedUser добавлен в группу';
                  subtitle = 'В: ${getGroupName(movement.toGroupId)}'
                             '\nДата: ${DateFormat('dd.MM.yyyy HH:mm').format(movement.movementDate.toLocal())}'
                             '${(movement.reason != null && movement.reason!.isNotEmpty) ? '\nПричина: ${movement.reason}' : ''}'
                             '\nИнициатор: $movedBy';
                }

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
