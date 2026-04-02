import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/providers/repair_time_standard_provider.dart';
import 'package:fitman_common/modules/equipment/repair_time_standard.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepairTimeStandardEditScreen extends ConsumerStatefulWidget {
  final RepairTimeStandard? standard;

  const RepairTimeStandardEditScreen({super.key, this.standard});

  @override
  ConsumerState<RepairTimeStandardEditScreen> createState() =>
      _RepairTimeStandardEditScreenState();
}

class _RepairTimeStandardEditScreenState
    extends ConsumerState<RepairTimeStandardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;
  String? _selectedEquipmentTypeId;
  RepairComplexity? _selectedComplexity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.standard?.name);
    _descriptionController =
        TextEditingController(text: widget.standard?.description);
    _durationController = TextEditingController(
        text: widget.standard?.standardDurationHours.toString());
    _selectedEquipmentTypeId = widget.standard?.equipmentTypeId;
    _selectedComplexity = widget.standard?.complexity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final equipmentTypesAsync = ref.watch(allEquipmentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.standard == null
            ? 'Новый норматив'
            : 'Редактировать норматив'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              equipmentTypesAsync.when(
                data: (types) => DropdownButtonFormField<String>(
                  initialValue: _selectedEquipmentTypeId,
                  decoration:
                      const InputDecoration(labelText: 'Тип оборудования'),
                  items: types
                      .map((type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEquipmentTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите тип оборудования';
                    }
                    return null;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Ошибка: $err'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                    labelText: 'Нормативное время (часы)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите время';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Неверный формат';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<RepairComplexity>(
                initialValue: _selectedComplexity,
                decoration: const InputDecoration(labelText: 'Сложность'),
                items: RepairComplexity.values
                    .map((complexity) => DropdownMenuItem(
                          value: complexity,
                          child: Text(complexity.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedComplexity = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newStandard = RepairTimeStandard(
        id: widget.standard?.id,
        name: _nameController.text,
        equipmentTypeId: _selectedEquipmentTypeId!,
        description: _descriptionController.text,
        standardDurationHours: double.parse(_durationController.text),
        complexity: _selectedComplexity,
      );

      final notifier = ref.read(repairTimeStandardNotifierProvider.notifier);
      if (widget.standard == null) {
        notifier.createStandard(newStandard);
      } else {
        notifier.updateStandard(widget.standard!.id!, newStandard);
      }

      Navigator.of(context).pop();
    }
  }
}
