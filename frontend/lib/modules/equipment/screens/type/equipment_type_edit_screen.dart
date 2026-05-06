import 'package:fitman_app/modules/equipment/utils/schematic_icons.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_category.enum.dart';
import 'package:fitman_common/modules/equipment/equipment/equipment_type.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';


class EquipmentTypeEditScreen extends ConsumerStatefulWidget {
  final String? equipmentTypeId;
  final EquipmentType? equipmentType;

  const EquipmentTypeEditScreen({
    super.key,
    this.equipmentTypeId,
    this.equipmentType,
  });

  @override
  ConsumerState<EquipmentTypeEditScreen> createState() =>
      _EquipmentTypeEditScreenState();
}

class _EquipmentTypeEditScreenState extends ConsumerState<EquipmentTypeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late EquipmentCategory _selectedCategory;
  late TextEditingController _weightRangeController;
  late TextEditingController _dimensionsController;

  late bool _isMobile;



  late String? _selectedSchematicIcon;


  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedCategory = EquipmentCategory.other; // Default value
    _weightRangeController = TextEditingController();
    _dimensionsController = TextEditingController();

    _isMobile = true; // Default value



    _selectedSchematicIcon = null;


    if (widget.equipmentType != null) {
      _populateForm(widget.equipmentType!);
    } else if (widget.equipmentTypeId != null) {
      _loadEquipmentType();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightRangeController.dispose();
    _dimensionsController.dispose();




    super.dispose();
  }

  void _populateForm(EquipmentType equipmentType) {
    _nameController.text = equipmentType.name;
    _descriptionController.text = equipmentType.description ?? '';
    _selectedCategory = equipmentType.category;
    _weightRangeController.text = equipmentType.weightRange ?? '';
    _dimensionsController.text = equipmentType.dimensions ?? '';

    _isMobile = equipmentType.isMobile;



    _selectedSchematicIcon = equipmentType.schematicIcon;

  }

  Future<void> _loadEquipmentType() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final equipmentType = await ref.read(equipmentTypeByIdProvider(widget.equipmentTypeId!).future);
      _populateForm(equipmentType);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final newEquipmentType = EquipmentType(
      id: widget.equipmentTypeId ?? '', // Will be updated by backend for new items
      name: _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      category: _selectedCategory,
      weightRange: _weightRangeController.text.isEmpty ? null : _weightRangeController.text,
      dimensions: _dimensionsController.text.isEmpty ? null : _dimensionsController.text,
      isMobile: _isMobile,
      schematicIcon: _selectedSchematicIcon,
    );
    
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      String message;
      if (widget.equipmentTypeId == null) {
        // Create new
        await ApiService.createEquipmentType(newEquipmentType);
        message = 'Тип оборудования успешно создан!';
      } else {
        // Update existing
        await ApiService.updateEquipmentType(widget.equipmentTypeId!, newEquipmentType);
        message = 'Тип оборудования успешно обновлен!';
        ref.invalidate(equipmentTypeByIdProvider(widget.equipmentTypeId!));
      }
      ref.invalidate(allEquipmentTypesProvider); // Invalidate all types to refresh the list

      if (!context.mounted) return; // Guard against BuildContext across async gaps
      
      // Pop first, then show SnackBar on the previous screen.
      navigator.pop(true); 
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Ошибка: $_errorMessage'), backgroundColor: Colors.red),
      );
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.equipmentTypeId == null
              ? 'Создать тип оборудования'
              : 'Редактировать тип оборудования',
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveForm,
                ),
        ],
      ),
      body: _isLoading && widget.equipmentTypeId != null && widget.equipmentType == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<EquipmentCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Категория'),
                      items: [
                        ...EquipmentCategory.values
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.displayName),
                                )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _weightRangeController,
                      decoration:
                          const InputDecoration(labelText: 'Диапазон веса'),
                    ),
                    TextFormField(
                      controller: _dimensionsController,
                      decoration: const InputDecoration(labelText: 'Габариты'),
                    ),

                    SwitchListTile(
                      title: const Text('Мобильное'),
                      value: _isMobile,
                      onChanged: (value) {
                        setState(() {
                          _isMobile = value;
                        });
                      },
                    ),



                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Схематичная иконка'),
                      initialValue: _selectedSchematicIcon,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Нет иконки')),
                        ...getSchematicIconNames().map((iconName) => DropdownMenuItem(
                          value: iconName,
                          child: Row(
                            children: [
                              Icon(getSchematicIcon(iconName)),
                              const SizedBox(width: 8),
                              Text(getSchematicIconDisplayName(iconName)),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSchematicIcon = value;
                        });
                      },
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
