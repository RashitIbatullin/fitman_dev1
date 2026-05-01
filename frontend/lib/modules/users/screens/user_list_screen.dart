// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitman_common/fitman_common.dart';
import '../../../services/api_service.dart';
import '../../employees/screens/create_employee_screen.dart';
import '../../clients/screens/client_dashboard.dart';
import '../../../screens/instructor_dashboard.dart';
import '../../../screens/manager_dashboard.dart';
import '../../../screens/trainer_dashboard.dart';
import '../../roles/screens/unknown_role_screen.dart';
import '../../employees/screens/edit_employee_screen.dart';
import '../../roles/widgets/role_dialog_manager.dart';
import '../../../widgets/reset_password_dialog.dart';
import '../../../widgets/filter_popup_menu.dart'; 


// 1. Providers for filters
final userRoleFilterProvider = StateProvider<String?>((ref) => 'all');
final userIsArchivedFilterProvider = StateProvider<bool>((ref) => false);

// Constants for pagination
const int _usersLimit = 20; // Number of users to fetch per page

// 2. Provider to fetch users based on filters and manage pagination
class EmployeesNotifier extends AsyncNotifier<List<User>> {
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<User>> build() async {
    _offset = 0; // Reset offset on build
    _hasMore = true;
    return _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    if (!_hasMore) return []; // No more data to fetch

    _isLoadingMore = true;
    if (state.hasValue) {
      state = AsyncData(state.value!);
    } else {
      state = const AsyncLoading();
    }

    try {
      final role = ref.watch(userRoleFilterProvider);
      final isArchived = ref.watch(userIsArchivedFilterProvider);

      final newUsers = await ApiService.getUsers(
        role: (role == 'all' || role == null) ? null : role,
        isArchived: isArchived,
        offset: _offset,
        limit: _usersLimit,
      );

      _isLoadingMore = false;

      if (newUsers.length < _usersLimit) {
        _hasMore = false;
      }

      if (_offset == 0) {
        return newUsers;
      } else {
        return [...?state.value, ...newUsers];
      }
    } catch (e) {
      _isLoadingMore = false;
      if (state.hasValue && _offset > 0) {
        return state.value!;
      }
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<void> loadMoreUsers() async {
    if (_isLoadingMore || !_hasMore) return;

    _offset += _usersLimit;
    state = AsyncData(await _fetchUsers());
  }

  Future<void> refreshUsers() async {
    _offset = 0;
    _hasMore = true;
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  void updateFilters(String? newRole, bool newIsArchived) {
    if (ref.read(userRoleFilterProvider) != newRole ||
        ref.read(userIsArchivedFilterProvider) != newIsArchived) {
      ref.read(userRoleFilterProvider.notifier).state = newRole;
      ref.read(userIsArchivedFilterProvider.notifier).state = newIsArchived;
      refreshUsers();
    }
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}

final employeesProvider = AsyncNotifierProvider<EmployeesNotifier, List<User>>(() {
  return EmployeesNotifier();
});

final newlyCreatedUserProvider = StateProvider<User?>((ref) => null);

class UserListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final ScrollController? scrollController;
  final bool showToolbar;

  const UserListScreen({
    super.key,
    this.initialFilter,
    this.scrollController,
    required this.showToolbar,
  });

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _archiveReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFilter != null) {
        ref.read(userRoleFilterProvider.notifier).state = widget.initialFilter;
      }
    });
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Only dispose the controller if it was created locally.
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _searchController.dispose();
    _archiveReasonController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !ref.read(employeesProvider.notifier).isLoadingMore &&
        ref.read(employeesProvider.notifier).hasMore) {
      ref.read(employeesProvider.notifier).loadMoreUsers();
    }
  }

  List<User> _filterUsers(List<User> allUsers) {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isEmpty) return allUsers;
    return allUsers.where((user) {
      return user.fullName.toLowerCase().contains(searchQuery) ||
          (user.phone?.toLowerCase().contains(searchQuery) ?? false) ||
          user.email.toLowerCase().contains(searchQuery);
    }).toList();
  }
  
  Future<void> _navigateToDashboard(BuildContext context, User user, String roleName) async {
    Widget page;
    switch (roleName) {
      case 'admin':
        return;
      case 'manager':
        page = ManagerDashboard(manager: user, showBackButton: true);
        break;
      case 'trainer':
        page = TrainerDashboard(trainer: user, showBackButton: true);
        break;
      case 'instructor':
        page = InstructorDashboard(instructor: user, showBackButton: true);
        break;
      case 'client':
        page = ClientDashboard(client: user, showBackButton: true);
        break;
      default:
        page = const UnknownRoleScreen();
    }
    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    ref.read(employeesProvider.notifier).refreshUsers();
  }

  String _getRoleDisplayName(Role role) => role.title;

  Color _getRoleColor(String roleName) {
    switch (roleName) {
      case 'admin': return Colors.purple;
      case 'manager': return Colors.orange;
      case 'trainer': return Colors.green;
      case 'instructor': return Colors.teal;
      case 'client': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _navigateToCreateUser(BuildContext context, String role) async {
    final newUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (context) => CreateEmployeeScreen(userRole: role)),
    );
    if (newUser != null) {
      ref.read(employeesProvider.notifier).refreshUsers();
      ref.read(newlyCreatedUserProvider.notifier).state = newUser;
    }
  }
  
  void _navigateToEditScreen(BuildContext context, User user) async {
     await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEmployeeScreen(user: user),
      ),
    );
    ref.read(employeesProvider.notifier).refreshUsers();
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать пользователя'),
        content: const Text('Выберите роль нового пользователя:'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'client'); }, child: const Text('Клиент')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'instructor'); }, child: const Text('Инструктор')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'trainer'); }, child: const Text('Тренер')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'manager'); }, child: const Text('Менеджер')),
          TextButton(onPressed: () { Navigator.pop(context); _navigateToCreateUser(context, 'admin'); }, child: const Text('Администратор')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        ],
      ),
    );
  }

  void _showArchiveUserDialog(BuildContext context, User user) async {
    _archiveReasonController.text = user.archivedReason ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите архивацию'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Вы уверены, что хотите архивировать пользователя "${user.fullName}"?'),
              TextFormField(
                controller: _archiveReasonController,
                decoration: const InputDecoration(hintText: 'Причина архивации (не менее 5 символов)*'),
                validator: (value) {
                  if (value == null || value.length < 5) {
                    return 'Причина должна содержать не менее 5 символов';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) Navigator.of(context).pop(true);
            },
            child: const Text('Архивировать'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.archiveUser(user.id, reason: _archiveReasonController.text.trim());
        ref.read(employeesProvider.notifier).refreshUsers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пользователь "${user.fullName}" успешно архивирован.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка архивации: $e')));
      }
    }
  }

  void _showDeArchiveUserDialog(BuildContext context, User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите деархивацию'),
        content: Text('Вы уверены, что хотите деархивировать пользователя "${user.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Деархивировать')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.updateUser(UpdateUserRequest(id: user.id, archivedAt: null));
        ref.read(employeesProvider.notifier).refreshUsers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пользователь "${user.fullName}" успешно деархивирован.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка деархивации: $e')));
      }
    }
  }

  void _showResetPasswordDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ResetPasswordDialog(userId: user.id, userName: user.fullName),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<User?>(newlyCreatedUserProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final roleName = next.roles.first.name;
          _navigateToDashboard(context, next, roleName);
          ref.read(newlyCreatedUserProvider.notifier).state = null;
        });
      }
    });

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.showToolbar ? 1.0 : 0.0,
            child: SizedBox(
              height: widget.showToolbar ? null : 0.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreateUserDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Создать'),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Поиск по ФИО/телефону/почте',
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterPopupMenuButton<String>(
                            tooltip: 'Фильтр по роли',
                            initialValue: ref.watch(userRoleFilterProvider),
                            onSelected: (value) => ref.read(userRoleFilterProvider.notifier).state = value,
                            allOptionText: 'Все роли',
                            options: const [
                              FilterOption(label: 'Администраторы', value: 'admin'),
                              FilterOption(label: 'Менеджеры', value: 'manager'),
                              FilterOption(label: 'Тренеры', value: 'trainer'),
                              FilterOption(label: 'Инструкторы', value: 'instructor'),
                              FilterOption(label: 'Клиенты', value: 'client'),
                            ],
                            avatar: const Icon(Icons.person_search_outlined),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Text('Архив'),
                              Switch(
                                value: ref.watch(userIsArchivedFilterProvider),
                                onChanged: (value) {
                                  ref.read(userIsArchivedFilterProvider.notifier).state = value;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ref.watch(employeesProvider).when(
            data: (allUsers) {
              final filteredUsers = _filterUsers(allUsers);
              final employeesNotifier = ref.read(employeesProvider.notifier);

              if (filteredUsers.isEmpty && !employeesNotifier.isLoadingMore) {
                return const Center(child: Text('Пользователи не найдены'));
              }
              return ListView.builder(
                controller: _scrollController,
                itemCount: filteredUsers.length + (employeesNotifier.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredUsers.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = filteredUsers[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: user.archivedAt != null ? Colors.grey[200] : null,
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(Uri.parse(ApiService.baseUrl).replace(path: user.photoUrl!).toString())
                            : null,
                        child: user.photoUrl == null ? Text(user.firstName.isNotEmpty ? user.firstName[0] : '?') : null,
                      ),
                      title: Row(
                        children: [
                          Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(width: 8),
                          if (user.roles.isNotEmpty)
                            Wrap(
                              spacing: 4.0,
                              runSpacing: 2.0,
                              children: user.roles
                                  .map((role) => Chip(
                                        label: Text(_getRoleDisplayName(role), style: const TextStyle(fontSize: 10)),
                                        backgroundColor: _getRoleColor(role.name),
                                        labelStyle: const TextStyle(color: Colors.white),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.zero,
                                      ))
                                  .toList(),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Theme.of(context).colorScheme.secondary),
                            Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                            const Text('•'),
                            Icon(Icons.phone_outlined, size: 14, color: Theme.of(context).colorScheme.secondary),
                            Text(user.phone ?? 'Нет телефона', style: Theme.of(context).textTheme.bodySmall),
                            if (user.roles.any((role) => role.name == 'client')) ...[
                              const Text('•'),
                              Icon(Icons.person_outline, size: 14, color: Theme.of(context).colorScheme.secondary),
                              Text(user.gender ?? 'Пол Н/Д', style: Theme.of(context).textTheme.bodySmall),
                              const Text('•'),
                              Icon(Icons.numbers, size: 14, color: Theme.of(context).colorScheme.secondary),
                              Text('Возраст: ${user.age?.toString() ?? 'Н/Д'}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                            if(user.archivedAt != null) ...[
                              const Text('•'),
                              Icon(Icons.archive_outlined, size: 14, color: Colors.blueGrey),
                              Text(
                                'В архиве ${user.archivedReason != null && user.archivedReason!.isNotEmpty ? '(${user.archivedReason})' : ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey)
                              ),
                            ]
                          ],
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _navigateToEditScreen(context, user);
                              break;
                            case 'reset_password':
                              _showResetPasswordDialog(context, user);
                              break;
                            case 'archive':
                              _showArchiveUserDialog(context, user);
                              break;
                            case 'deactivate':
                              _showDeArchiveUserDialog(context, user);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          if (user.archivedAt == null) ...[
                            const PopupMenuItem<String>(value: 'edit', child: Text('Изменить')),
                            const PopupMenuItem<String>(value: 'reset_password', child: Text('Сбросить пароль')),
                            const PopupMenuItem<String>(value: 'archive', child: Text('Архивировать')),
                          ] else ...[
                            const PopupMenuItem<String>(value: 'deactivate', child: Text('Деархивировать')),
                          ],
                        ],
                      ),
                      onTap: () async {
                        if (user.roles.length > 1) {
                          final selectedRole = await RoleDialogManager.show(context, user.roles);
                          if (selectedRole != null) await _navigateToDashboard(context, user, selectedRole.name);
                        } else if (user.roles.isNotEmpty) {
                          await _navigateToDashboard(context, user, user.roles.first.name);
                        } else {
                          await _navigateToDashboard(context, user, '');
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка: $error')),
          ),
        ),
      ],
    );
  }
}
