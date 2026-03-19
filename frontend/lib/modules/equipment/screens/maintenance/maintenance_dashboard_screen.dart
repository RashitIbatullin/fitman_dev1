import 'package:flutter/material.dart';

class MaintenanceDashboardScreen extends StatelessWidget {
  const MaintenanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ТО оборудования'),
      ),
      body: const Center(
        child: Text('Здесь будет дашборд ТО'),
      ),
    );
  }
}
