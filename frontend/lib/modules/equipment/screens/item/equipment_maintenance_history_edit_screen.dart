import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/maintenance/providers/maintenance_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:intl/intl.dart';

// Helper class to manage photos and their comments
class _PhotoWithComment {
  final PlatformFile file;
  final TextEditingController commentController;

  _PhotoWithComment(this.file) : commentController = TextEditingController();
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

  // Controllers for the new model fields
  late TextEditingController _reportedProblemController;
  late TextEditingController _workDescriptionController;
  late MaintenanceType _selectedType;
  late MaintenanceStatus _selectedStatus;
  
  // State for holding picked files with comments
  final List<_PhotoWithComment> _beforePhotos = [];
  final List<_PhotoWithComment> _afterPhotos = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _reportedProblemController = TextEditingController(text: record?.reportedProblem ?? '');
    _workDescriptionController = TextEditingController(text: record?.workDescription ?? '');
    _selectedType = record?.type ?? MaintenanceType.corrective;
    _selectedStatus = record?.status ?? MaintenanceStatus.reported;

    // TODO: Implement loading existing photos for editing
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

  Future<void> _pickFiles(List<_PhotoWithComment> photoList) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        photoList.addAll(result.files.map((file) => _PhotoWithComment(file)));
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

      if (isCreating) {
        recordToSave = EquipmentMaintenanceHistory(
          id: '', // Ignored by backend on create
          equipmentItemId: widget.equipmentItemId,
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text,
          type: _selectedType,
          status: _selectedStatus,
          reportedBy: '', // This should be the current user ID, handled by backend/provider
        );
        recordToSave = await ApiService.createMaintenanceHistory(recordToSave);
      } else {
        recordToSave = widget.historyRecord!.copyWith(
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text,
          type: _selectedType,
          status: _selectedStatus,
        );
        recordToSave = await ApiService.updateMaintenanceHistory(recordToSave.id, recordToSave);
      }

      // Upload photos with comments
      for (final photo in _beforePhotos) {
        if (photo.file.bytes != null) {
          await ApiService.uploadMaintenancePhoto(
            maintenanceId: recordToSave.id,
            photoBytes: photo.file.bytes!,
            fileName: photo.file.name,
            timing: PhotoTiming.before.name,
            comment: photo.commentController.text,
          );
        }
      }
      for (final photo in _afterPhotos) {
         if (photo.file.bytes != null) {
          await ApiService.uploadMaintenancePhoto(
            maintenanceId: recordToSave.id,
            photoBytes: photo.file.bytes!,
            fileName: photo.file.name,
            timing: PhotoTiming.after.name,
            comment: photo.commentController.text,
          );
        }
      }
      
      ref.invalidate(maintenanceHistoryProvider(widget.equipmentItemId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись сохранена'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) return;
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
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип ТО', border: OutlineInputBorder()),
                items: MaintenanceType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(toBeginningOfSentenceCase(type.name) ?? type.name));
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
                  return DropdownMenuItem(value: status, child: Text(toBeginningOfSentenceCase(status.name) ?? status.name));
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
                validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
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
  
  Widget _buildPhotoSection(BuildContext context, String title, List<_PhotoWithComment> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 180, // Increased height to accommodate the text field
          child: photos.isEmpty
              ? const Center(child: Text('Нет выбранных фото'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SizedBox(
                        width: 150, // Set a fixed width for the item
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Image.memory(photo.file.bytes!, width: 150, height: 100, fit: BoxFit.cover),
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
                            SizedBox(
                              height: 50,
                              child: TextFormField(
                                controller: photo.commentController,
                                decoration: const InputDecoration(
                                  labelText: 'Примечание',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                                ),
                                style: const TextStyle(fontSize: 12),
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
