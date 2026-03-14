import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/models/available_executor.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:intl/intl.dart';

// Helper class to manage existing and new photos
class _PhotoHolder {
  final MaintenancePhoto? existingPhoto;
  final PlatformFile? newFile;
  final TextEditingController commentController;

  _PhotoHolder({this.existingPhoto, this.newFile})
      : commentController = TextEditingController(text: existingPhoto?.comment ?? ''),
        assert(existingPhoto != null || newFile != null);

  bool get isNew => newFile != null;
  String? get url => existingPhoto?.url;
  String get id => existingPhoto?.id ?? newFile!.name;
}

class EquipmentMaintenanceHistoryEditScreen extends ConsumerStatefulWidget {
  final String equipmentItemId;
  final EquipmentMaintenanceHistory? historyRecord;

  const EquipmentMaintenanceHistoryEditScreen({
    super.key,
    required this.equipmentItemId,
    this.historyRecord,
  });

  @override
  ConsumerState<EquipmentMaintenanceHistoryEditScreen> createState() =>
      _EquipmentMaintenanceHistoryEditScreenState();
}

class _EquipmentMaintenanceHistoryEditScreenState
    extends ConsumerState<EquipmentMaintenanceHistoryEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _reportedProblemController;
  late TextEditingController _workDescriptionController;
  late TextEditingController _startedAtController;
  late TextEditingController _completedAtController;
  late TextEditingController _executorNameController;

  late MaintenanceType _selectedType;
  late MaintenanceStatus _selectedStatus;
  String? _executorId;
  ExecutorType? _executorType;

  final List<_PhotoHolder> _beforePhotos = [];
  final List<_PhotoHolder> _afterPhotos = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _reportedProblemController = TextEditingController(text: record?.reportedProblem ?? '');
    _workDescriptionController = TextEditingController(text: record?.workDescription ?? '');
    
    final startedAt = record?.startedAt;
    _startedAtController = TextEditingController(
        text: startedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(startedAt.toLocal()) : '');
    
    final completedAt = record?.completedAt;
    _completedAtController = TextEditingController(
        text: completedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(completedAt.toLocal()) : '');

    _selectedType = record?.type ?? MaintenanceType.corrective;
    _selectedStatus = record?.status ?? MaintenanceStatus.reported;

    _executorNameController = TextEditingController(text: record?.executorName ?? '');
    _executorId = record?.executorId;
    _executorType = record?.executorType;

    // Populate photo lists from existing record
    if (record?.photos != null) {
      print('--- Populating photos from record ---');
      for (final photo in record!.photos!) {
        print('Photo ID: ${photo.id}, Timing: ${photo.timing}');
        final holder = _PhotoHolder(existingPhoto: photo);
        if (photo.timing == PhotoTiming.before) {
          _beforePhotos.add(holder);
        } else if (photo.timing == PhotoTiming.after) {
          _afterPhotos.add(holder);
        }
      }
      print('--- Finished populating photos ---');
    }
  }

  @override
  void dispose() {
    _reportedProblemController.dispose();
    _workDescriptionController.dispose();
    _startedAtController.dispose();
    _completedAtController.dispose();
    _executorNameController.dispose();
    for (var photo in _beforePhotos) {
      photo.commentController.dispose();
    }
    for (var photo in _afterPhotos) {
      photo.commentController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles(List<_PhotoHolder> photoList) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        photoList.addAll(result.files.map((file) => _PhotoHolder(newFile: file)));
      });
    }
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (date == null) return;

    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
    
      if (time == null) return;

      final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      controller.text = DateFormat('yyyy-MM-dd HH:mm').format(newDateTime);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isCreating = widget.historyRecord == null;
      EquipmentMaintenanceHistory recordToSave;

      final authState = ref.read(authProvider);
      final userId = authState.valueOrNull?.user?.id;

      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: не удалось определить пользователя'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }

      final startedAt = _startedAtController.text.isNotEmpty ? DateTime.parse(_startedAtController.text) : null;
      final completedAt = _completedAtController.text.isNotEmpty ? DateTime.parse(_completedAtController.text) : null;

      if (isCreating) {
        recordToSave = EquipmentMaintenanceHistory(
          id: null,
          equipmentItemId: widget.equipmentItemId,
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text.isNotEmpty ? _workDescriptionController.text : null,
          type: _selectedType,
          status: _selectedStatus,
          reportedBy: userId.toString(),
          startedAt: startedAt,
          completedAt: completedAt,
          executorId: _executorId,
          executorType: _executorType,
        );
        recordToSave = await ApiService.createMaintenanceHistory(recordToSave);
      } else {
        recordToSave = widget.historyRecord!.copyWith(
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text,
          type: _selectedType,
          status: _selectedStatus,
          startedAt: startedAt,
          completedAt: completedAt,
          executorId: _executorId,
          executorType: _executorType,
        );
        recordToSave = await ApiService.updateMaintenanceHistory(recordToSave.id!, recordToSave);
      }

      // Upload new photos with comments
      for (final photo in _beforePhotos.where((p) => p.isNew)) {
        final platformFile = photo.newFile!;
        final photoBytes = platformFile.bytes ?? (platformFile.path != null ? await File(platformFile.path!).readAsBytes() : null);

        if (photoBytes != null) {
          await ApiService.uploadMaintenancePhoto(
            maintenanceId: recordToSave.id!,
            photoBytes: photoBytes,
            fileName: platformFile.name,
            timing: PhotoTiming.before.name,
            comment: photo.commentController.text,
          );
        }
      }
      for (final photo in _afterPhotos.where((p) => p.isNew)) {
        final platformFile = photo.newFile!;
        final photoBytes = platformFile.bytes ?? (platformFile.path != null ? await File(platformFile.path!).readAsBytes() : null);

        if (photoBytes != null) {
          await ApiService.uploadMaintenancePhoto(
            maintenanceId: recordToSave.id!,
            photoBytes: photoBytes,
            fileName: platformFile.name,
            timing: PhotoTiming.after.name,
            comment: photo.commentController.text,
          );
        }
      }
      
      ref.invalidate(allMaintenanceHistoryProvider);
      ref.invalidate(maintenanceHistoryProvider(widget.equipmentItemId));


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись сохранена'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);

    } catch (e, st) {
      if (!mounted) return;
      
      print('--- SAVE FAILED ---');
      print('ERROR: $e');
      print('STACK TRACE: $st');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.historyRecord == null ? 'Новая заявка на ТО' : 'Редактировать заявку'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<MaintenanceType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип ТО', border: OutlineInputBorder()),
                items: MaintenanceType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.title));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MaintenanceStatus>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),
                items: MaintenanceStatus.values.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status.title));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
               TextFormField(
                controller: _executorNameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Исполнитель',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.person_search),
                    onPressed: _showExecutorSelectionDialog,
                  ),
                ),
                onTap: _showExecutorSelectionDialog,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reportedProblemController,
                decoration: const InputDecoration(
                    labelText: 'Описание проблемы',
                    hintText: 'Минимум 5 символов',
                    border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().length < 5) {
                    return 'Описание должно быть не менее 5 символов.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workDescriptionController,
                decoration: const InputDecoration(
                    labelText: 'Описание выполненных работ',
                    hintText: 'Минимум 5 символов',
                    border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.trim().length < 5) {
                    return 'Описание должно быть не менее 5 символов.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startedAtController,
                      decoration: InputDecoration(
                        labelText: 'Начата',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDateTime(_startedAtController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(_startedAtController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _completedAtController,
                      decoration: InputDecoration(
                        labelText: 'Завершена',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDateTime(_completedAtController),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDateTime(_completedAtController),
                      validator: (value) {
                        if (value == null || value.isEmpty || _startedAtController.text.isEmpty) {
                          return null;
                        }
                        final startDate = DateTime.tryParse(_startedAtController.text);
                        final endDate = DateTime.tryParse(value);

                        if (startDate != null && endDate != null) {
                          if (!endDate.isAfter(startDate)) {
                            return 'Дата завершения должна быть после даты начала';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPhotoSection(context, 'Фото "До"', _beforePhotos),
              const SizedBox(height: 16),
              _buildPhotoSection(context, 'Фото "После"', _afterPhotos),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _showExecutorSelectionDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ExecutorSelectionDialog(),
    );

    if (result != null) {
      setState(() {
        _executorId = result['id'];
        _executorType = result['type'];
        _executorNameController.text = result['name'];
      });
    }
  }
  
  Widget _buildPhotoSection(BuildContext context, String title, List<_PhotoHolder> photos) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: photos.isEmpty
              ? const Center(child: Text('Нет фото'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photoHolder = photos[index];
                    
                    ImageProvider? image;
                    if (photoHolder.isNew) {
                      if (photoHolder.newFile?.bytes != null) {
                        image = MemoryImage(photoHolder.newFile!.bytes!);
                      }
                    } else {
                      image = NetworkImage('$baseUrl${photoHolder.url}');
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                if (image != null)
                                  Image(image: image, width: 150, height: 100, fit: BoxFit.cover)
                                else
                                  Container(width: 150, height: 100, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => photos.removeAt(index));
                                    },
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: TextFormField(
                                controller: photoHolder.commentController,
                                maxLines: null, // Allows multiline
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  labelText: 'Примечание',
                                  hintText: photoHolder.isNew ? 'Мин. 5 символов' : '',
                                  border: photoHolder.isNew ? const OutlineInputBorder() : InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                ),
                                style: const TextStyle(fontSize: 12),
                                readOnly: !photoHolder.isNew,
                                validator: (v) {
                                  if (photoHolder.isNew && (v == null || v.trim().length < 5)) {
                                    return 'Мин. 5 симв.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Добавить фото'),
          onPressed: () => _pickFiles(photos),
        ),
      ],
    );
  }
}

class _ExecutorSelectionDialog extends ConsumerStatefulWidget {
  const _ExecutorSelectionDialog();

  @override
  ConsumerState<_ExecutorSelectionDialog> createState() => __ExecutorSelectionDialogState();
}

class __ExecutorSelectionDialogState extends ConsumerState<_ExecutorSelectionDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final executorsAsync = ref.watch(availableExecutorsProvider);

    return AlertDialog(
      title: const Text('Выбор исполнителя'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: executorsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Ошибка: $err')),
          data: (data) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Поиск...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Сотрудники'),
                      Tab(text: 'Внешний персонал'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildExecutorList(data.users, ExecutorType.user),
                        _buildExecutorList(data.staff, ExecutorType.staff),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }

  Widget _buildExecutorList(List<Executor> executors, ExecutorType type) {
    final filteredList = executors.where((e) {
      final fullName = ('${e.firstName ?? ''} ${e.lastName ?? ''}').toLowerCase().trim();
      return fullName.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final executor = filteredList[index];
        final displayName = ('${executor.lastName ?? ''} ${executor.firstName ?? ''}').trim();
        return ListTile(
          title: Text(displayName.isNotEmpty ? displayName : 'Имя не указано'),
          onTap: () {
            Navigator.of(context).pop({
              'id': executor.id,
              'name': displayName.isNotEmpty ? displayName : 'Имя не указано',
              'type': type,
            });
          },
        );
      },
    );
  }
}
