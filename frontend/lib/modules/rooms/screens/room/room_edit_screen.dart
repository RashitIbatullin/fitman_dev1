import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/rooms/providers/room/building_provider.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import '../../models/room/room.model.dart';
import '../../models/room/room_type.enum.dart';
import '../../utils/room_utils.dart';

class RoomEditScreen extends ConsumerStatefulWidget {
  final Room room;
  const RoomEditScreen({super.key, required this.room});

  @override
  ConsumerState<RoomEditScreen> createState() => _RoomEditScreenState();
}

class _RoomEditScreenState extends ConsumerState<RoomEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _roomNumberController;
  late TextEditingController _floorController;
  late TextEditingController _maxCapacityController;
  late TextEditingController _areaController;
  late TextEditingController _deactivationReasonController;

  String? _selectedBuildingId;
  late RoomType _selectedRoomType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _descriptionController = TextEditingController(text: widget.room.description);
    _roomNumberController = TextEditingController(text: widget.room.roomNumber);
    _floorController = TextEditingController(text: widget.room.floor?.toString()); // Changed
    _maxCapacityController = TextEditingController(text: widget.room.maxCapacity.toString());
    _areaController = TextEditingController(text: widget.room.area?.toString());
    _deactivationReasonController = TextEditingController(text: widget.room.deactivateReason);

    _selectedBuildingId = widget.room.buildingId;
    _selectedRoomType = widget.room.type;
    _isActive = widget.room.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _roomNumberController.dispose();
    _floorController.dispose();
    _maxCapacityController.dispose();
    _areaController.dispose();
    _deactivationReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать помещение'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Название
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
              // 2. Тип
              DropdownButtonFormField<RoomType>(
                initialValue: _selectedRoomType,
                decoration: const InputDecoration(labelText: 'Тип помещения *'),
                items: RoomType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 24),
                        const SizedBox(width: 10),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRoomType = value;
                    });
                  }
                },
                validator: (value) =>
                    value == null ? 'Пожалуйста, выберите тип помещения' : null,
              ),
              // 3. Описание
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              // 4. Вместимость
              TextFormField(
                controller: _maxCapacityController,
                decoration:
                    const InputDecoration(labelText: 'Макс. вместимость *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите вместимость';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null) {
                    return 'Введите корректное число';
                  }
                  if (capacity <= 0) {
                    return 'Вместимость должна быть больше 0';
                  }
                  return null;
                },
              ),
              // 5. Корпус
              buildingsAsync.when(
                data: (buildings) => DropdownButtonFormField<String>(
                  initialValue: _selectedBuildingId,
                  decoration: const InputDecoration(labelText: 'Здание *'),
                  items: buildings
                      .where((b) => b.archivedAt == null)
                      .map((building) {
                    return DropdownMenuItem<String>(
                      value: building.id,
                      child: Text(building.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBuildingId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Пожалуйста, выберите здание' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Text('Не удалось загрузить здания: $err'),
              ),
              // 6. Этаж
              TextFormField(
                controller: _floorController,
                decoration: const InputDecoration(labelText: 'Этаж'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              // 7. Номер комнаты
              TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(labelText: 'Номер комнаты'),
              ),
              // 8. Площадь
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Площадь (м²)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // 9. Status Box
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Активно'),
                      value: _isActive,
                      onChanged: (value) {
                        _handleActivityChange(value);
                      },
                    ),
                    if (!_isActive)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TextFormField(
                          controller: _deactivationReasonController,
                          decoration:
                              const InputDecoration(labelText: 'Причина деактивации'),
                          enabled: false,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRoom,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleActivityChange(bool value) {
    if (value) {
      // If activating, just update the state
      setState(() {
        _isActive = true;
        _deactivationReasonController.clear();
      });
    } else {
      // If deactivating, show the dialog
      _showDeactivationDialog();
    }
  }

  void _showDeactivationDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Деактивировать помещение'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              decoration:
                  const InputDecoration(labelText: 'Причина деактивации'),
              validator: (value) {
                if (value == null || value.trim().length < 5) {
                  return 'Причина должна содержать не менее 5 символов.';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: reasonController,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: value.text.trim().length >= 5
                      ? () {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              _isActive = false;
                              _deactivationReasonController.text =
                                  reasonController.text;
                            });
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: const Text('Деактивировать'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _updateRoom() async {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authProvider).value;
      final userId = authState?.user?.id;

      final updatedRoom = widget.room.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        roomNumber: _roomNumberController.text,
        type: _selectedRoomType,
        floor: int.tryParse(_floorController.text), // Changed
        buildingId: _selectedBuildingId,
        maxCapacity: int.tryParse(_maxCapacityController.text) ?? 0,
        area: double.tryParse(_areaController.text),
        isActive: _isActive,
        deactivateReason: !_isActive ? _deactivationReasonController.text : null,
        deactivateAt: !_isActive ? DateTime.now() : null,
        deactivateBy: !_isActive ? userId?.toString() : null,
      );

      try {
        await ApiService.updateRoom(updatedRoom.id, updatedRoom);
        ref.invalidate(allRoomsProvider); // Invalidate provider to refetch updated rooms
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при обновлении помещения: $e')),
          );
        }
      }
    }
  }
}
