import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/maintenance/providers/maintenance_provider.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/services/api_service.dart';

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
  late MaintenanceType _selectedType;
  late MaintenanceStatus _selectedStatus;

  final List<_PhotoHolder> _beforePhotos = [];
  final List<_PhotoHolder> _afterPhotos = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _reportedProblemController = TextEditingController(text: record?.reportedProblem ?? '');
    _workDescriptionController = TextEditingController(text: record?.workDescription ?? '');
    _selectedType = record?.type ?? MaintenanceType.corrective;
    _selectedStatus = record?.status ?? MaintenanceStatus.reported;

    // Populate photo lists from existing record
    if (record?.photos != null) {
      for (final photo in record!.photos!) {
        final holder = _PhotoHolder(existingPhoto: photo);
        if (photo.timing == PhotoTiming.before) {
          _beforePhotos.add(holder);
        } else if (photo.timing == PhotoTiming.after) {
          _afterPhotos.add(holder);
        }
      }
    }
  }

  @override
  void dispose() {
    _reportedProblemController.dispose();
    _workDescriptionController.dispose();
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

      if (isCreating) {
        recordToSave = EquipmentMaintenanceHistory(
          id: null,
          equipmentItemId: widget.equipmentItemId,
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text.isNotEmpty ? _workDescriptionController.text : null,
          type: _selectedType,
          status: _selectedStatus,
          reportedBy: userId.toString(),
        );
        recordToSave = await ApiService.createMaintenanceHistory(recordToSave);
      } else {
        recordToSave = widget.historyRecord!.copyWith(
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text,
          type: _selectedType,
          status: _selectedStatus,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<MaintenanceType>(
                value: _selectedType,
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
                value: _selectedStatus,
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
                controller: _reportedProblemController,
                decoration: const InputDecoration(labelText: 'Описание проблемы', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Обязательное поле';
                  }
                  if (v.length < 5) {
                    return 'Описание должно быть не менее 5 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workDescriptionController,
                decoration: const InputDecoration(labelText: 'Описание выполненных работ', border: OutlineInputBorder()),
                maxLines: 3,
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
  
  Widget _buildPhotoSection(BuildContext context, String title, List<_PhotoHolder> photos) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: photos.isEmpty
              ? const Center(child: Text('Нет фото'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photoHolder = photos[index];
                    
                    final ImageProvider image;
                    if (photoHolder.isNew) {
                      image = MemoryImage(photoHolder.newFile!.bytes!);
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
                                Image(image: image, width: 150, height: 100, fit: BoxFit.cover),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() => photos.removeAt(index));
                                      // Note: This does not delete the photo from the server.
                                      // A dedicated API call would be needed for that.
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
                            SizedBox(
                              height: 50,
                              child: TextFormField(
                                controller: photoHolder.commentController,
                                decoration: const InputDecoration(
                                  labelText: 'Примечание',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                                style: const TextStyle(fontSize: 12),
                                // TODO: Add logic to save updated comments
                                readOnly: !photoHolder.isNew,
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
