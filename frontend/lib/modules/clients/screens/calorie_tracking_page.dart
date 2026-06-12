import 'package:flutter/material.dart';
import 'calorie_tracking_screen.dart';

class CalorieTrackingPage extends StatelessWidget {
  const CalorieTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Учет калорий'),
      ),
      body: const CalorieTrackingScreen(),
    );
  }
}
