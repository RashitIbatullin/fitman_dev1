import 'package:fitman_app/modules/rooms/models/building/building.model.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/room/building_provider.dart';

class BuildingEditScreen extends ConsumerStatefulWidget {
  final Building building;
  const BuildingEditScreen({super.key, required this.building});

  @override
  ConsumerState<BuildingEditScreen> createState() => _BuildingEditScreenState();
}

class _BuildingEditScreenState extends ConsumerState<BuildingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.building.name);
    _addressController = TextEditingController(text: widget.building.address);
    _noteController = TextEditingController(text: widget.building.note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать здание'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Адрес *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите адрес';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Заметка'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBuilding,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateBuilding() async {
    if (_formKey.currentState!.validate()) {
      final updatedBuilding = widget.building.copyWith(
        name: _nameController.text,
        address: _addressController.text,
        note: _noteController.text,
      );

      try {
        await ApiService.updateBuilding(widget.building.id, updatedBuilding);
        ref.invalidate(allBuildingsProvider);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при обновлении здания: $e')),
          );
        }
      }
    }
  }
}
