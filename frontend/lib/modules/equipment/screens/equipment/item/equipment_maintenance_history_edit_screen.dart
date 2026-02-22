import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/maintenance/providers/maintenance_provider.dart';
import 'package:fitman_app/services/api_service.dart';

// A simple class to hold a file and its note controller
class PhotoFile {
  final PlatformFile file;
  final TextEditingController noteController;
  PhotoFile(this.file, this.noteController);
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
  late TextEditingController _dateSentController;
  late TextEditingController _dateReturnedController;
  late TextEditingController _descriptionController;
  late TextEditingController _performedByController;

  // State for holding picked files and their notes
  final List<PhotoFile> _beforeFiles = [];
  final List<PhotoFile> _afterFiles = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _dateSentController = TextEditingController(text: record?.dateSent.toLocal().toString().substring(0, 10) ?? DateTime.now().toLocal().toString().substring(0, 10));
    _dateReturnedController = TextEditingController(text: record?.dateReturned?.toLocal().toString().substring(0, 10) ?? '');
    _descriptionController = TextEditingController(text: record?.descriptionOfWork ?? '');
    _performedByController = TextEditingController(text: record?.performedBy ?? '');
  }

  @override
  void dispose() {
    _dateSentController.dispose();
    _dateReturnedController.dispose();
    _descriptionController.dispose();
    _performedByController.dispose();
    for (var pf in _beforeFiles) {
      pf.noteController.dispose();
    }
    for (var pf in _afterFiles) {
      pf.noteController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFiles(List<PhotoFile> fileList) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // Important to get bytes
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          fileList.add(PhotoFile(file, TextEditingController()));
        }
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
          id: '', // Will be ignored by backend create
          equipmentItemId: widget.equipmentItemId,
          dateSent: DateTime.parse(_dateSentController.text),
          dateReturned: _dateReturnedController.text.isEmpty ? null : DateTime.parse(_dateReturnedController.text),
          descriptionOfWork: _descriptionController.text,
          performedBy: _performedByController.text.isEmpty ? null : _performedByController.text,
          photos: [], // Photos will be uploaded separately
        );
        recordToSave = await ApiService.createMaintenanceHistory(recordToSave);
      } else {
        recordToSave = widget.historyRecord!.copyWith(
          dateSent: DateTime.parse(_dateSentController.text),
          dateReturned: _dateReturnedController.text.isEmpty ? null : DateTime.parse(_dateReturnedController.text),
          descriptionOfWork: _descriptionController.text,
          performedBy: _performedByController.text.isEmpty ? null : _performedByController.text,
        );
        recordToSave = await ApiService.updateMaintenanceHistory(recordToSave.id, recordToSave);
      }

      // Upload photos
      for (final photoFile in _beforeFiles) {
        if (photoFile.file.bytes != null) {
          await ApiService.uploadMaintenancePhoto(
            maintenanceId: recordToSave.id,
            photoBytes: photoFile.file.bytes!,
            fileName: photoFile.file.name,
            comment: photoFile.noteController.text,
            timing: 'before',
          );
        }
      }
      for (final photoFile in _afterFiles) {
        if (photoFile.file.bytes != null) {
          await ApiService.uploadMaintenancePhoto(
            maintenanceId: recordToSave.id,
            photoBytes: photoFile.file.bytes!,
            fileName: photoFile.file.name,
            comment: photoFile.noteController.text,
            timing: 'after',
          );
        }
      }
      
      ref.invalidate(maintenanceHistoryProvider(widget.equipmentItemId));
      ref.invalidate(allMaintenanceHistoryProvider);

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
        title: Text(widget.historyRecord == null ? 'Добавить запись о ТО' : 'Редактировать запись'),
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
              TextFormField(
                controller: _dateSentController,
                decoration: InputDecoration(labelText: 'Дата отправки', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _dateSentController))),
                readOnly: true,
                validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateReturnedController,
                decoration: InputDecoration(labelText: 'Дата возврата', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _dateReturnedController))),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание работ', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _performedByController,
                decoration: const InputDecoration(labelText: 'Кем выполнено', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              _buildPhotoSection(context, 'Фото "До"', _beforeFiles, 'before'),
              const SizedBox(height: 16),
              _buildPhotoSection(context, 'Фото "После"', _afterFiles, 'after'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPhotoSection(BuildContext context, String title, List<PhotoFile> files, String timing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 160, // Increased height to accommodate note field
          child: files.isEmpty
              ? const Center(child: Text('Нет выбранных фото'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final photoFile = files[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 120,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                if (photoFile.file.bytes != null)
                                  Image.memory(photoFile.file.bytes!, width: 100, height: 100, fit: BoxFit.cover),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        // Dispose of the note controller when removing the photo
                                        photoFile.noteController.dispose();
                                        files.removeAt(index);
                                      });
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
                                controller: photoFile.noteController,
                                decoration: const InputDecoration(
                                  labelText: 'Примечание',
                                  border: OutlineInputBorder(),
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
          onPressed: () => _pickFiles(files),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toLocal().toIso8601String().substring(0, 10);
    }
  }
}
