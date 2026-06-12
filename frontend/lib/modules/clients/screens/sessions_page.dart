import 'package:flutter/material.dart';
import 'sessions_screen.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Занятия'),
      ),
      body: const SessionsScreen(),
    );
  }
}
