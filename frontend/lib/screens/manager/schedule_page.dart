import 'package:flutter/material.dart';
import 'schedule_view.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
      ),
      body: const ScheduleView(),
    );
  }
}
