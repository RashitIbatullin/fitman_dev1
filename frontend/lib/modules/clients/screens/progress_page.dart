import 'package:flutter/material.dart';
import 'progress_screen.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Прогресс'),
      ),
      body: const ProgressScreen(),
    );
  }
}
