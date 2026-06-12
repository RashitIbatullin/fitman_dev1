import 'package:flutter/material.dart';
import 'my_trainer_screen.dart';

class MyTrainerPage extends StatelessWidget {
  const MyTrainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой тренер'),
      ),
      body: const MyTrainerScreen(),
    );
  }
}
