import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/maintenance/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/maintenance/providers/maintenance_provider.dart';
import 'package:fitman_app/services/api_service.dart';

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
  late TextEditingController _costController;
  late TextEditingController _performedByController;
  
  // State for holding picked files
  final List<PlatformFile> _beforeFiles = [];
  final List<PlatformFile> _afterFiles = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _dateSentController = TextEditingController(text: record?.dateSent.toLocal().toString().substring(0, 10) ?? DateTime.now().toLocal().toString().substring(0, 10));
    _dateReturnedController = TextEditingController(text: record?.dateReturned?.toLocal().toString().substring(0, 10) ?? '');
    _descriptionController = TextEditingController(text: record?.descriptionOfWork ?? '');
    _performedByController = TextEditingController(text: record?.performedBy ?? '');

    // Note: We can't edit existing photos with this new mechanism, only add new ones.
    // This is a simplification for this step.
  }

  @override
  void dispose() {
    _dateSentController.dispose();
    _dateReturnedController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _performedByController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles(List<PlatformFile> fileList) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        fileList.addAll(result.files);
      });
    }
  }
  
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // First, create/update the record to get an ID
      final isCreating = widget.historyRecord == null;
      EquipmentMaintenanceHistory recordToSave;

      if (isCreating) {
        // Create a temporary record without photos
        recordToSave = EquipmentMaintenanceHistory(
          id: '', // Will be ignored by backend create
          equipmentItemId: widget.equipmentItemId,
          dateSent: DateTime.parse(_dateSentController.text),
          dateReturned: _dateReturnedController.text.isEmpty ? null : DateTime.parse(_dateReturnedController.text),
          descriptionOfWork: _descriptionController.text,
          performedBy: _performedByController.text.isEmpty ? null : _performedByController.text,
          photos: [], // Empty for now
        );
        recordToSave = await ApiService.createMaintenanceHistory(recordToSave);
      } else {
        recordToSave = widget.historyRecord!;
         // Update other fields if necessary
        final updatedRecord = recordToSave.copyWith(
          dateSent: DateTime.parse(_dateSentController.text),
          dateReturned: _dateReturnedController.text.isEmpty ? null : DateTime.parse(_dateReturnedController.text),
          descriptionOfWork: _descriptionController.text,
          performedBy: _performedByController.text.isEmpty ? null : _performedByController.text,
        );
        recordToSave = await ApiService.updateMaintenanceHistory(updatedRecord.id, updatedRecord);
      }

      // Now, upload photos with the record ID
      for (final file in _beforeFiles) {
        await ApiService.uploadMaintenancePhoto(
          maintenanceId: recordToSave.id,
          photoBytes: file.bytes!,
          fileName: file.name,
          timing: 'before',
        );
      }
      for (final file in _afterFiles) {
        await ApiService.uploadMaintenancePhoto(
          maintenanceId: recordToSave.id,
          photoBytes: file.bytes!,
          fileName: file.name,
          timing: 'after',
        );
      }
      
      ref.invalidate(maintenanceHistoryProvider(widget.equipmentItemId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Запись сохранена'), backgroundColor: Colors.green),
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
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Стоимость', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _performedByController,
                decoration: const InputDecoration(labelText: 'Кем выполнено', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              _buildPhotoSection(context, 'Фото "До"', _beforeFiles),
              const SizedBox(height: 16),
              _buildPhotoSection(context, 'Фото "После"', _afterFiles),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPhotoSection(BuildContext context, String title, List<PlatformFile> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: files.isEmpty
              ? const Center(child: Text('Нет выбранных фото'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          Image.memory(file.bytes!, width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
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
