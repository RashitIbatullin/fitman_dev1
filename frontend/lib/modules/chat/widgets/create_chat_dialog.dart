import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart'; // Adjusted relative path
import '../../../services/api_service.dart'; // Adjusted relative path
import '../../../modules/users/models/user.dart'; // Adjusted relative path

class CreateChatDialog extends ConsumerStatefulWidget {
  const CreateChatDialog({super.key});

  @override
  ConsumerState<CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends ConsumerState<CreateChatDialog> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<User> _allUsers = [];
  final List<User> _selectedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final currentUser = ref.read(authProvider).value?.user;
      if (currentUser == null) {
        throw Exception('Current user not authenticated.');
      }
      // Assuming ApiService has a method to get all users
      final users = await ApiService.getUsers();
      if (!mounted) return; // Guard against context use after dispose
      setState(() {
        // Filter out current user
        _allUsers.clear();
        _allUsers.addAll(users.where((user) => user.id != currentUser.id));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Guard against context use after dispose
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createChat() async {
    if (_selectedUsers.isEmpty) {
      if (!mounted) return; // Guard against context use after dispose
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите хотя бы одного пользователя.')),
      );
      return;
    }

    try {
      final selectedUserIds = _selectedUsers.map((user) => user.id).toList();
      int newChatId;

      if (_selectedUsers.length == 1 && _groupNameController.text.isEmpty) {
        // Private chat
        newChatId = await ApiService.createOrGetPrivateChat(selectedUserIds.first);
      } else {
        // Group chat
        final newChat = await ApiService.createGroupChat(_groupNameController.text.trim(), selectedUserIds);
        newChatId = newChat.id;
      }
      
      if (!mounted) return; // Guard against context use after dispose
      // TODO: Navigate to the new chat screen
      Navigator.of(context).pop(newChatId); // Return new chat ID
    } catch (e) {
      if (!mounted) return; // Guard against context use after dispose
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания чата: $_error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        title: Text('Загрузка пользователей...'),
        content: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AlertDialog(
        title: const Text('Ошибка'),
        content: Text('$_error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Создать новый чат'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Название группового чата (опционально)',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Выберите участников:'),
            ..._allUsers.map((user) => CheckboxListTile(
                  title: Text('${user.firstName} ${user.lastName}'),
                  value: _selectedUsers.contains(user),
                  onChanged: (bool? selected) {
                    _toggleUserSelection(user);
                  },
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _createChat,
          child: const Text('Создать чат'),
        ),
      ],
    );
  }
}