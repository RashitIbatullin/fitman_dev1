import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';

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
  
  final List<TextEditingController> _photoUrlControllers = [];
  final List<TextEditingController> _photoNoteControllers = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _dateSentController = TextEditingController(text: record?.dateSent.toLocal().toString().substring(0, 10) ?? '');
    _dateReturnedController = TextEditingController(text: record?.dateReturned?.toLocal().toString().substring(0, 10) ?? '');
    _descriptionController = TextEditingController(text: record?.descriptionOfWork ?? '');
    _costController = TextEditingController(text: record?.cost?.toString() ?? '');
    _performedByController = TextEditingController(text: record?.performedBy ?? '');

    if (record?.photos != null) {
      for (var photo in record?.photos ?? []) {
        _photoUrlControllers.add(TextEditingController(text: photo.url));
        _photoNoteControllers.add(TextEditingController(text: photo.note));
      }
    }
  }

  @override
  void dispose() {
    _dateSentController.dispose();
    _dateReturnedController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _performedByController.dispose();
    for (var controller in _photoUrlControllers) {
      controller.dispose();
    }
    for (var controller in _photoNoteControllers) {
      controller.dispose();
    }
    super.dispose();
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

  void _addPhotoField() {
    setState(() {
      _photoUrlControllers.add(TextEditingController());
      _photoNoteControllers.add(TextEditingController());
    });
  }

  void _removePhotoField(int index) {
    setState(() {
      _photoUrlControllers[index].dispose();
      _photoNoteControllers[index].dispose();
      _photoUrlControllers.removeAt(index);
      _photoNoteControllers.removeAt(index);
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final photos = <MaintenancePhoto>[];
    for (int i = 0; i < _photoUrlControllers.length; i++) {
      final url = _photoUrlControllers[i].text;
      if (url.isNotEmpty) {
        photos.add(MaintenancePhoto(
          url: url,
          note: _photoNoteControllers[i].text,
        ));
      }
    }

    final newRecord = EquipmentMaintenanceHistory(
      id: widget.historyRecord?.id ?? '',
      equipmentItemId: widget.equipmentItemId,
      dateSent: DateTime.parse(_dateSentController.text),
      dateReturned: _dateReturnedController.text.isEmpty ? null : DateTime.parse(_dateReturnedController.text),
      descriptionOfWork: _descriptionController.text,
      cost: _costController.text.isEmpty ? null : double.tryParse(_costController.text),
      performedBy: _performedByController.text.isEmpty ? null : _performedByController.text,
      photos: photos,
    );

    try {
      final notifier = ref.read(equipmentProvider.notifier);
      if (widget.historyRecord == null) {
        await notifier.createMaintenanceHistory(newRecord);
      } else {
        await notifier.updateMaintenanceHistory(widget.historyRecord!.id, newRecord);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
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
              Text('Фотографии', style: Theme.of(context).textTheme.titleLarge),
              ..._buildPhotoFields(),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Добавить фото'),
                onPressed: _addPhotoField,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPhotoFields() {
    final fields = <Widget>[];
    for (int i = 0; i < _photoUrlControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _photoUrlControllers[i],
                      decoration: const InputDecoration(labelText: 'URL Фото', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _photoNoteControllers[i],
                      decoration: const InputDecoration(labelText: 'Примечание к фото', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removePhotoField(i),
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }
}