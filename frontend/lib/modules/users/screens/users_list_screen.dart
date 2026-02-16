// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../../roles/models/role.dart';
import '../../../services/api_service.dart';
import 'create_user_screen.dart';
import '../../../screens/client_dashboard.dart';
import '../../../screens/instructor_dashboard.dart';
import '../../../screens/manager_dashboard.dart';
import '../../../screens/trainer_dashboard.dart';
import '../../roles/screens/unknown_role_screen.dart';
import 'edit_user_screen.dart';
import '../../roles/widgets/role_dialog_manager.dart';
import '../../../widgets/reset_password_dialog.dart';
import '../../../widgets/filter_popup_menu.dart'; // Add this import


// 1. Providers for filters
final userRoleFilterProvider = StateProvider<String?>((ref) => 'all');
final userIsArchivedFilterProvider = StateProvider<bool?>((ref) => false);

// Constants for pagination
const int _usersLimit = 20; // Number of users to fetch per page

// 2. Provider to fetch users based on filters and manage pagination
class UsersNotifier extends AsyncNotifier<List<User>> {
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
    // Notify listeners about loading state
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
        _hasMore = false; // No more data if fewer than limit are returned
      }

      if (_offset == 0) {
        // Initial load or refresh
        return newUsers;
      } else {
        // Load more, append to existing list
        return [...?state.value, ...newUsers];
      }
    } catch (e) {
      _isLoadingMore = false;
      // If there was an error and we have previous data, keep it
      if (state.hasValue && _offset > 0) {
        return state.value!;
      }
      throw Exception('Failed to fetch users: $e'); // Re-throw to handle error in UI
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

  // Override to handle filter changes
  void updateFilters(String? newRole, bool? newIsArchived) {
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

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(() {
  return UsersNotifier();
});

final newlyCreatedUserProvider = StateProvider<User?>((ref) => null);

class UsersListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final ScrollController scrollController;
  final bool showToolbar;

  const UsersListScreen({
    super.key,
    this.initialFilter,
    required this.scrollController,
    required this.showToolbar,
  });

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  User? _selectedUser;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _archiveReasonController = TextEditingController(); // Added for archive reason
  final _formKey = GlobalKey<FormState>(); // Added FormState key

  @override
  void initState() {
    super.initState();
    // Set initial filter from widget if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFilter != null) {
        ref.read(userRoleFilterProvider.notifier).state = widget.initialFilter;
      }
    });
    _searchController.addListener(() {
      // We only need to call setState to trigger a rebuild for the search
      setState(() {});
    });

    // Add scroll listener for pagination
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _archiveReasonController.dispose(); // Dispose controller
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController.position.pixels >=
            widget.scrollController.position.maxScrollExtent * 0.8 && // 80% scrolled
        !ref.read(usersProvider.notifier).isLoadingMore &&
        ref.read(usersProvider.notifier).hasMore) {
      ref.read(usersProvider.notifier).loadMoreUsers();
    }
  }

  List<User> _filterUsers(List<User> allUsers) {
    List<User> users = allUsers; // The provider already filtered by role/status

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      users = users.where((user) {
        return user.fullName.toLowerCase().contains(searchQuery) ||
            (user.phone?.toLowerCase().contains(searchQuery) ?? false) ||
            user.email.toLowerCase().contains(searchQuery);
      }).toList();
    }
    
    // This is a workaround to deselect user if they are filtered out.
    if (_selectedUser != null && !users.any((u) => u.id == _selectedUser!.id)) {
      Future.microtask(() => setState(() => _selectedUser = null));
    }

    return users;
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
    // Refresh data on return
    ref.read(usersProvider.notifier).refreshUsers();
  }

  String _getRoleDisplayName(Role role) {
    return role.title;
  }

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
    final newUser = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateUserScreen(userRole: role)),
    );

    if (newUser != null && newUser is User) {
      ref.read(usersProvider.notifier).refreshUsers(); // Refresh and refetch
      ref.read(newlyCreatedUserProvider.notifier).state = newUser;
    }
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

  void _showArchiveUserDialog(BuildContext context) async {
    final userToArchive = _selectedUser; // Create a local non-nullable variable
    if (userToArchive == null) return; // Check it here

    // Reset the text field before showing the dialog
    _archiveReasonController.text = userToArchive.archivedReason ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите архивацию'),
        content: Form( // Wrap with Form for validation
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Вы уверены, что хотите архивировать пользователя "${userToArchive.fullName}"?'),
              TextFormField( // Use TextFormField for validation
                controller: _archiveReasonController,
                decoration: const InputDecoration(
                  hintText: 'Причина архивации (не менее 5 символов)*',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Причина архивации обязательна';
                  }
                  if (value.length < 5) {
                    return 'Причина должна содержать не менее 5 символов';
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
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) { // Validate on press
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Архивировать'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.archiveUser(userToArchive.id, reason: _archiveReasonController.text.trim());
        // Refresh the user list after successful archival
        ref.read(usersProvider.notifier).refreshUsers();
        // Deselect the user
        setState(() {
          _selectedUser = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пользователь "${userToArchive.fullName}" успешно архивирован.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка архивации пользователя: $e')),
        );
      }
    }
  }

  void _showDeArchiveUserDialog(BuildContext context) async {
    final userToDeArchive = _selectedUser;
    if (userToDeArchive == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите деархивацию'),
        content: Text('Вы уверены, что хотите деархивировать пользователя "${userToDeArchive.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Деархивировать'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.updateUser(UpdateUserRequest(id: userToDeArchive.id, archivedAt: null));
        // Refresh the user list after successful de-archival
        ref.read(usersProvider.notifier).refreshUsers();
        // Deselect the user
        setState(() {
          _selectedUser = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пользователь "${userToDeArchive.fullName}" успешно деархивирован.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка деархивации пользователя: $e')),
        );
      }
    }
  }

  void _showResetPasswordDialog(BuildContext context) {
    if (_selectedUser == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResetPasswordDialog(userId: _selectedUser!.id, userName: _selectedUser!.fullName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<User?>(newlyCreatedUserProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final roleName = next.roles.first.name;
          Widget? page;
          switch (roleName) {
            case 'client':
              page = ClientDashboard(client: next, showBackButton: true);
              break;
            case 'manager':
              page = ManagerDashboard(manager: next, showBackButton: true);
              break;
            case 'trainer':
              page = TrainerDashboard(trainer: next, showBackButton: true);
              break;
            case 'instructor':
              page = InstructorDashboard(instructor: next, showBackButton: true);
              break;
            case 'admin':
              // Admins likely stay on the users list, so no navigation.
              break;
          }

          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            ).then((_) {
              // Reset the provider after navigation
              ref.read(newlyCreatedUserProvider.notifier).state = null;
            });
          } else {
            // Reset the provider even if there's no navigation
            ref.read(newlyCreatedUserProvider.notifier).state = null;
          }
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
              child: Padding( // Added Padding to replicate _UsersToolbar's padding
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Explicitly align children to start
                  children: [
                    Row(
                      children: [
                        FilterPopupMenuButton<String>(
                          tooltip: 'Действия',
                          initialValue: null,
                          onSelected: (value) async {
                            switch (value) {
                              case 'create':
                                _showCreateUserDialog(context);
                                break;
                              case 'edit':
                                if (_selectedUser != null) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUserScreen(user: _selectedUser!),
                                    ),
                                  );
                                  ref.read(usersProvider.notifier).refreshUsers();
                                }
                                break;
                              case 'reset_password':
                                _showResetPasswordDialog(context);
                                break;
                              case 'archive':
                                _showArchiveUserDialog(context);
                                break;
                              case 'deactivate': // Renamed from 'deArchive' for consistency with isActive
                                _showDeArchiveUserDialog(context);
                                break;
                            }
                          },
                          allOptionText: 'Действия', // Default text for the button
                          showAllOption: false, // Hide the "Действия" option in the dropdown
                          options: [
                            const FilterOption(label: 'Создать пользователя', value: 'create'),
                            FilterOption(
                              label: 'Изменить пользователя',
                              value: 'edit',
                              enabled: _selectedUser != null && _selectedUser!.archivedAt == null,
                            ),
                            FilterOption(
                              label: 'Сбросить пароль',
                              value: 'reset_password',
                              enabled: _selectedUser != null && _selectedUser!.archivedAt == null,
                            ),
                            FilterOption(
                              label: 'Архивировать пользователя',
                              value: 'archive',
                              enabled: _selectedUser != null && _selectedUser!.archivedAt == null,
                            ),
                            FilterOption(
                              label: 'Деархивировать пользователя',
                              value: 'deactivate',
                              enabled: _selectedUser != null && _selectedUser!.archivedAt != null,
                            ),
                          ],
                          avatar: const Icon(Icons.more_vert),
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
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchController.clear(),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(), // Moved Spacer to the end
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // FilterPopupMenuButton for role filter
                          FilterPopupMenuButton<String>(
                            tooltip: 'Фильтр по роли',
                            initialValue: ref.watch(userRoleFilterProvider),
                            onSelected: (value) {
                              ref.read(userRoleFilterProvider.notifier).state = value;
                            },
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
                          // FilterPopupMenuButton for archived filter
                          FilterPopupMenuButton<bool>(
                            tooltip: 'Фильтр по архивации',
                            initialValue: ref.watch(userIsArchivedFilterProvider),
                            onSelected: (value) {
                              ref.read(userIsArchivedFilterProvider.notifier).state = value;
                              ref.read(usersProvider.notifier).refreshUsers();
                            },
                            allOptionText: 'Статус: Все', // This needs to be changed
                            options: const [
                              FilterOption(label: 'В архиве', value: true),
                              FilterOption(label: 'Не в архиве', value: false),
                            ],
                            avatar: const Icon(Icons.archive_outlined),
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
          child: ref.watch(usersProvider).when(
            data: (allUsers) {
              final filteredUsers = _filterUsers(allUsers);
              final usersNotifier = ref.read(usersProvider.notifier);
              final isLoadingMore = usersNotifier.isLoadingMore;
              final hasMore = usersNotifier.hasMore;

              if (filteredUsers.isEmpty && !isLoadingMore && !hasMore) {
                return const Center(child: Text('Пользователи не найдены'));
              }
              return ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredUsers.length + (isLoadingMore && hasMore ? 1 : 0), // Add 1 for loading indicator only if currently loading more and hasMore
                itemBuilder: (context, index) {
                  if (index == filteredUsers.length) {
                    // This is the loading indicator at the end
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = filteredUsers[index];
                  final isSelected = _selectedUser?.id == user.id;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: isSelected ? Theme.of(context).primaryColor.withAlpha(25) : (user.archivedAt != null ? Colors.grey[200] : null),
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
                              children: user.roles.map((role) => Chip(
                                      label: Text(_getRoleDisplayName(role), style: const TextStyle(fontSize: 10,),),
                                      backgroundColor: _getRoleColor(role.name,),
                                      labelStyle: const TextStyle(color: Colors.white,),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      padding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Wrap(
                          spacing: 8.0, // Increased spacing for better readability
                          runSpacing: 4.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Theme.of(context).colorScheme.secondary),
                            Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                            const Text('•'),
                            Icon(Icons.phone_outlined, size: 14, color: Theme.of(context).colorScheme.secondary),
                            Text(user.phone ?? 'Нет телефона', style: Theme.of(context).textTheme.bodySmall),
                            // Add client-specific info here
                            if (user.roles.any((role) => role.name == 'client')) ...[
                              const Text('•'),
                              Icon(Icons.person_outline, size: 14, color: Theme.of(context).colorScheme.secondary),
                              Text(user.gender ?? 'Пол Н/Д', style: Theme.of(context).textTheme.bodySmall),
                              const Text('•'),
                              Icon(Icons.numbers, size: 14, color: Theme.of(context).colorScheme.secondary),
                              Text('Возраст: ${user.age?.toString() ?? 'Н/Д'}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                            if(user.archivedAt != null) ...[
                              const Text('•'), // Separator before status
                              Icon(
                                Icons.archive_outlined,
                                size: 14,
                                color: Colors.blueGrey,
                              ),
                              Text(
                                'В архиве ${user.archivedReason != null && user.archivedReason!.isNotEmpty ? '(${user.archivedReason})' : ''}', // Display reason
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.blueGrey,
                                )
                              ),
                            ]
                          ],
                        ),
                      ),
                      trailing: null,
                      onTap: () async {
                        final context_ = context;
                        if (user.roles.length > 1) {
                          final selectedRole = await RoleDialogManager.show(context_, user.roles,);
                          if (selectedRole != null) {
                            await _navigateToDashboard(context_, user, selectedRole.name,);
                          }
                        } else if (user.roles.isNotEmpty) {
                          await _navigateToDashboard(context_, user, user.roles.first.name,);
                        } else {
                          await _navigateToDashboard(context_, user, '');
                        }
                      },
                      onLongPress: () {
                        setState(() {
                          _selectedUser = isSelected ? null : user;
                        });
                      },
                    ),
                  );
                },
              );
            },
            loading: () {
              // If we have some data already, display it with a loading indicator at the end
              if (ref.read(usersProvider).value != null && ref.read(usersProvider).value!.isNotEmpty) {
                final loadedUsers = ref.read(usersProvider).value!;
                final filteredUsers = _filterUsers(loadedUsers);
                final usersNotifier = ref.read(usersProvider.notifier);
                final isLoadingMore = usersNotifier.isLoadingMore;
                final hasMore = usersNotifier.hasMore; // Ensure hasMore is correctly read

                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: filteredUsers.length + (isLoadingMore && hasMore ? 1 : 0), // Add 1 for loading indicator only if currently loading more and hasMore
                  itemBuilder: (context, index) {
                    if (index == filteredUsers.length) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final user = filteredUsers[index];
                    final isSelected = _selectedUser?.id == user.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: isSelected ? Theme.of(context).primaryColor.withAlpha(25) : null,
                      child: ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(Uri.parse(ApiService.baseUrl).replace(path: user.photoUrl!).toString())
                              : null,
                          child: user.photoUrl == null ? Text(user.firstName.isNotEmpty ? user.firstName[0] : '?') : null,
                        ),
                        title: Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(user.email),
                        onTap: () async {
                          final context_ = context;
                          if (user.roles.length > 1) {
                            final selectedRole = await RoleDialogManager.show(context_, user.roles,);
                            if (selectedRole != null) {
                              await _navigateToDashboard(context_, user, selectedRole.name,);
                            }
                          } else if (user.roles.isNotEmpty) {
                            await _navigateToDashboard(context_, user, user.roles.first.name,);
                          } else {
                            await _navigateToDashboard(context_, user, '');
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _selectedUser = isSelected ? null : user;
                          });
                        },
                      ),
                    );
                  },
                );
              }
              // Otherwise, show a full-screen loading indicator for the initial load
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stack) => Center(child: Text('Ошибка: $error')),
          ),
        ),
      ],
    );
  }
}