import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/rooms/providers/room/building_provider.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import '../../models/room/room.model.dart';
import '../../models/room/room_type.enum.dart';
import '../../utils/room_utils.dart';

class RoomCreateScreen extends ConsumerStatefulWidget {
  const RoomCreateScreen({super.key});

  @override
  ConsumerState<RoomCreateScreen> createState() => _RoomCreateScreenState();
}

class _RoomCreateScreenState extends ConsumerState<RoomCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomNumberController = TextEditingController(); // New controller
  final _floorController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedBuildingId;
  RoomType? _selectedRoomType; // Changed to nullable
  bool _buildingDefaultSet = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _roomNumberController.dispose();
    _floorController.dispose();
    _maxCapacityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать помещение'),
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
                  setState(() {
                    _selectedRoomType = value;
                  });
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
                data: (buildings) {
                  final activeBuildings =
                      buildings.where((b) => b.archivedAt == null).toList();
                  if (activeBuildings.length == 1 && !_buildingDefaultSet) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _selectedBuildingId = activeBuildings.first.id;
                          _buildingDefaultSet = true;
                        });
                      }
                    });
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedBuildingId,
                    decoration: const InputDecoration(labelText: 'Здание *'),
                    items: activeBuildings.map((building) {
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
                  );
                },
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
                  if (value != null &&
                      value.isNotEmpty &&
                      int.tryParse(value) == null) {
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createRoom,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createRoom() async {
    if (_formKey.currentState!.validate()) {
      final newRoom = Room(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        roomNumber: _roomNumberController.text, // New field
        type: _selectedRoomType!, // Ensure type is not null
        floor: int.tryParse(_floorController.text), // Changed to parse int
        buildingId: _selectedBuildingId,
        maxCapacity: int.tryParse(_maxCapacityController.text) ?? 0,
        area: double.tryParse(_areaController.text),
        photoUrls: [],
        workingDays: [], // Default to empty
      );

      try {
        await ApiService.createRoom(newRoom);
        ref.invalidate(allRoomsProvider); // Invalidate to refetch the list
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка при создании помещения: $e')),
          );
        }
      }
    }
  }
}

