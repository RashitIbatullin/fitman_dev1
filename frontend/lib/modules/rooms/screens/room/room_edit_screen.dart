import 'package:fitman_app/modules/rooms/room_type_extensions.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/rooms/providers/room/building_provider.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:fitman_common/modules/rooms/room.model.dart';
import 'package:fitman_common/modules/rooms/room_type.enum.dart';
import 'package:fitman_common/modules/rooms/building.model.dart';

import 'package:fitman_common/modules/rooms/room_schedule.model.dart';
import 'package:fitman_common/custom/time_of_day_custom.dart';

import 'package:fitman_app/providers/room_schedule_provider.dart';
import '../../../users/providers/auth_provider.dart';

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
  List<RoomSchedule> _editedSchedules = [];

  String? _selectedBuildingId;
  late RoomType _selectedRoomType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _descriptionController = TextEditingController(text: widget.room.description);
    _roomNumberController = TextEditingController(text: widget.room.roomNumber);
    _floorController = TextEditingController(text: widget.room.floor?.toString());
    _maxCapacityController = TextEditingController(text: widget.room.maxCapacity.toString());
    _areaController = TextEditingController(text: widget.room.area?.toString());
    _deactivationReasonController = TextEditingController(text: widget.room.deactivateReason);

    _selectedBuildingId = widget.room.buildingId;
    _selectedRoomType = widget.room.type;
    _isActive = widget.room.isActive;

    // Fetch initial schedules after widget is built, ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomScheduleProvider(widget.room.id)).when(
            data: (schedules) {
              setState(() {
                _editedSchedules = schedules.map((s) => s.copyWith()).toList();
              });
            },
            loading: () {
              // Optionally show a loading indicator or use default schedules
              setState(() {
                _editedSchedules = _createDefaultEditedSchedules(widget.room.id);
              });
            },
            error: (err, st) {
              // Handle error, maybe show a snackbar or use default schedules
              setState(() {
                _editedSchedules = _createDefaultEditedSchedules(widget.room.id);
              });
            },
          );
    });
  }

  // Helper to create default schedules for editing if none loaded or on error
  List<RoomSchedule> _createDefaultEditedSchedules(String roomId) {
    return List.generate(7, (index) {
      final day = index + 1; // 1 = Monday, ..., 7 = Sunday
      final isWorking = day < 6; // Mon-Fri default to working
      return RoomSchedule(
        id: '', // Placeholder ID for new schedules (will be assigned by backend)
        roomId: roomId,
        dayOfWeek: day,
        isWorkingDay: isWorking,
        openTime: isWorking ? TimeOfDayCustom.parse('09:00:00') : null, // Default working hours
        closeTime: isWorking ? TimeOfDayCustom.parse('21:00:00') : null,
      );
    });
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

  String _getWeekdayName(int day) {
    switch (day) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      case 7:
        return 'Воскресенье';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(allBuildingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Редактировать: ${widget.room.name}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Основное'),
              Tab(text: 'Расписание'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              // 1. Основное
              _buildMainInfoEditor(buildingsAsync),
              // 2. Расписание
              _buildScheduleEditor(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _updateRoom,
          label: const Text('Сохранить'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildMainInfoEditor(AsyncValue<List<Building>> buildingsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
            data: (buildings) {
              final activeBuildings = buildings.where((b) => b.archivedAt == null).toList();
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
          SwitchListTile(
            title: const Text('Активно'),
            value: _isActive,
            onChanged: (value) {
              _handleActivityChange(value);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          ),
          if (!_isActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                controller: _deactivationReasonController,
                decoration:
                    const InputDecoration(labelText: 'Причина деактивации'),
                enabled: false,
              ),
            ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildScheduleEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(_editedSchedules.length, (index) {
          final schedule = _editedSchedules[index];
          final isWorkingDay = schedule.isWorkingDay;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(_getWeekdayName(schedule.dayOfWeek)),
                    value: isWorkingDay,
                    onChanged: (value) {
                      setState(() {
                        _editedSchedules[index] = schedule.copyWith(isWorkingDay: value);
                      });
                    },
                  ),
                  if (isWorkingDay) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickOpenTime(context, index),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Время открытия',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                schedule.openTime?.toJson() ?? 'Выбрать время',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickCloseTime(context, index),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Время закрытия',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                schedule.closeTime?.toJson() ?? 'Выбрать время',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _pickOpenTime(BuildContext context, int index) async {
    final initialTime = _editedSchedules[index].openTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialTime?.hour ?? 9,
        minute: initialTime?.minute ?? 0,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        _editedSchedules[index] = _editedSchedules[index].copyWith(
          openTime: TimeOfDayCustom(hour: pickedTime.hour, minute: pickedTime.minute),
        );
      });
    }
  }

  Future<void> _pickCloseTime(BuildContext context, int index) async {
    final initialTime = _editedSchedules[index].closeTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialTime?.hour ?? 21,
        minute: initialTime?.minute ?? 0,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        _editedSchedules[index] = _editedSchedules[index].copyWith(
          closeTime: TimeOfDayCustom(hour: pickedTime.hour, minute: pickedTime.minute),
        );
      });
    }
  }

  Future<void> _handleActivityChange(bool value) async {
    if (value) {
      setState(() {
        _isActive = true;
        _deactivationReasonController.clear();
      });
    } else {
      final reason = await _showDeactivationDialog();
      if (reason != null && reason.isNotEmpty) {
        setState(() {
          _isActive = false;
          _deactivationReasonController.text = reason;
        });
      }
    }
  }

  Future<String?> _showDeactivationDialog() {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
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
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Отмена'),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: reasonController,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: value.text.trim().length >= 5
                      ? () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop(reasonController.text.trim());
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
        await ApiService.updateRoomSchedules(widget.room.id, _editedSchedules);
        ref.invalidate(allRoomsProvider); // Invalidate provider to refetch updated rooms
        ref.invalidate(roomByIdProvider(widget.room.id));
        ref.invalidate(roomScheduleProvider(widget.room.id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Помещение успешно обновлено')),
          );
          Navigator.of(context).pop(true);
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
