import 'package:flutter/material.dart';
import 'my_instructor_screen.dart';

class MyInstructorPage extends StatelessWidget {
  const MyInstructorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой инструктор'),
      ),
      body: const MyInstructorScreen(),
    );
  }
}
