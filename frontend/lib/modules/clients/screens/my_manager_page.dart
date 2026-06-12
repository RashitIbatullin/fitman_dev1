import 'package:flutter/material.dart';
import 'my_manager_screen.dart';

class MyManagerPage extends StatelessWidget {
  const MyManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой менеджер'),
      ),
      body: const MyManagerScreen(),
    );
  }
}
