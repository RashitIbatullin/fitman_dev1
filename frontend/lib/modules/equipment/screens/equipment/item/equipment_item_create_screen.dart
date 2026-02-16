import 'package:flutter/material.dart';

class EquipmentItemCreateScreen extends StatelessWidget {
  const EquipmentItemCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание Оборудования'),
      ),
      body: Center(
        child: Text('Здесь будет форма создания оборудования.'),
      ),
    );
  }
}
