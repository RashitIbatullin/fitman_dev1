import 'package:flutter/material.dart';
import '../../modules/users/screens/user_list_screen.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
      ),
      body: const UserListScreen(showToolbar: true),
    );
  }
}
