import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_item.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'equipment_maintenance_history_edit_screen.dart';
import 'package:fitman_app/modules/rooms/models/room/room.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_type.model.dart';

class EquipmentItemEditScreen extends ConsumerStatefulWidget {
  final String? itemId; // For existing item
  final EquipmentItem? equipmentItem; // For pre-filling existing

  const EquipmentItemEditScreen({
    super.key,
    this.itemId,
    this.equipmentItem,
  });

  @override
  ConsumerState<EquipmentItemEditScreen> createState() =>
      _EquipmentItemEditScreenState();
}

class _EquipmentItemEditScreenState
    extends ConsumerState<EquipmentItemEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _inventoryNumberController;
  late TextEditingController _serialNumberController;
  late TextEditingController _modelController;
  late TextEditingController _manufacturerController;
  late TextEditingController _placementNoteController;
  late EquipmentStatus _selectedStatus;
  late int _conditionRating;
  late TextEditingController _conditionNotesController;
  late TextEditingController _lastMaintenanceDateController;
  late TextEditingController _nextMaintenanceDateController;
  late TextEditingController _maintenanceNotesController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _supplierController;
  late TextEditingController _warrantyMonthsController;
  late TextEditingController _usageHoursController;
  late TextEditingController _lastUsedDateController;

  String? _initialEquipmentTypeId;
  String? _initialRoomId;
  EquipmentType? _selectedEquipmentType;
  Room? _selectedRoom;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _inventoryNumberController = TextEditingController();
    _serialNumberController = TextEditingController();
    _modelController = TextEditingController();
    _manufacturerController = TextEditingController();
    _placementNoteController = TextEditingController();
    _selectedStatus = EquipmentStatus.available; // Default
    _conditionRating = 5; // Default
    _conditionNotesController = TextEditingController();
    _lastMaintenanceDateController = TextEditingController();
    _nextMaintenanceDateController = TextEditingController();
    _maintenanceNotesController = TextEditingController();
    _purchaseDateController = TextEditingController();
    _purchasePriceController = TextEditingController();
    _supplierController = TextEditingController();
    _warrantyMonthsController = TextEditingController();
    _usageHoursController = TextEditingController(text: '0'); // Default
    _lastUsedDateController = TextEditingController();

    if (widget.equipmentItem != null) {
      _populateForm(widget.equipmentItem!);
      _selectedEquipmentType = null; 
      _selectedRoom = null; 
    } else if (widget.itemId != null) {
      _loadEquipmentItem();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inventoryNumberController.dispose();
    _serialNumberController.dispose();
    _modelController.dispose();
    _manufacturerController.dispose();
    _placementNoteController.dispose();
    _conditionNotesController.dispose();
    _lastMaintenanceDateController.dispose();
    _nextMaintenanceDateController.dispose();
    _maintenanceNotesController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    _supplierController.dispose();
    _warrantyMonthsController.dispose();
    _usageHoursController.dispose();
    _lastUsedDateController.dispose();
    super.dispose();
  }

  void _populateForm(EquipmentItem item) {
    _inventoryNumberController.text = item.inventoryNumber;
    _serialNumberController.text = item.serialNumber ?? '';
    _modelController.text = item.model ?? '';
    _manufacturerController.text = item.manufacturer ?? '';
    _placementNoteController.text = item.placementNote ?? '';
    _selectedStatus = item.status;
    _conditionRating = item.conditionRating;
    _conditionNotesController.text = item.conditionNotes ?? '';
    _lastMaintenanceDateController.text =
        item.lastMaintenanceDate?.toLocal().toIso8601String().substring(0, 10) ?? '';
    _nextMaintenanceDateController.text =
        item.nextMaintenanceDate?.toLocal().toIso8601String().substring(0, 10) ?? '';
    _maintenanceNotesController.text = item.maintenanceNotes ?? '';
    _purchaseDateController.text =
        item.purchaseDate?.toLocal().toIso8601String().substring(0, 10) ?? '';
    _purchasePriceController.text = item.purchasePrice?.toString() ?? '';
    _supplierController.text = item.supplier ?? '';
    _warrantyMonthsController.text = item.warrantyMonths?.toString() ?? '';
    _usageHoursController.text = item.usageHours.toString();
    _lastUsedDateController.text =
        item.lastUsedDate?.toLocal().toIso8601String().substring(0, 10) ?? '';

    _initialEquipmentTypeId = item.typeId;
    _initialRoomId = item.roomId;
  }

  Future<void> _loadEquipmentItem() async {
    setState(() => _isLoading = true);
    try {
      final item = await ref.read(equipmentItemByIdProvider(widget.itemId!).future);
       if(mounted) {
        _populateForm(item);
       }
    } catch (e) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEquipmentType == null) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, выберите тип оборудования.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final isCreating = widget.itemId == null;

    final equipmentItem = EquipmentItem(
      id: isCreating ? '' : widget.itemId!,
      typeId: _selectedEquipmentType!.id,
      inventoryNumber: _inventoryNumberController.text,
      serialNumber: _serialNumberController.text.isEmpty ? null : _serialNumberController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
      manufacturer: _manufacturerController.text.isEmpty ? null : _manufacturerController.text,
      roomId: _selectedRoom?.id,
      placementNote: _placementNoteController.text.isEmpty ? null : _placementNoteController.text,
      status: _selectedStatus,
      conditionRating: _conditionRating,
      conditionNotes: _conditionNotesController.text.isEmpty ? null : _conditionNotesController.text,
      lastMaintenanceDate: _lastMaintenanceDateController.text.isEmpty ? null : DateTime.parse(_lastMaintenanceDateController.text),
      nextMaintenanceDate: _nextMaintenanceDateController.text.isEmpty ? null : DateTime.parse(_nextMaintenanceDateController.text),
      maintenanceNotes: _maintenanceNotesController.text.isEmpty ? null : _maintenanceNotesController.text,
      purchaseDate: _purchaseDateController.text.isEmpty ? null : DateTime.parse(_purchaseDateController.text),
      purchasePrice: _purchasePriceController.text.isEmpty ? null : double.tryParse(_purchasePriceController.text),
      supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
      warrantyMonths: _warrantyMonthsController.text.isEmpty ? null : int.tryParse(_warrantyMonthsController.text),
      usageHours: int.tryParse(_usageHoursController.text) ?? 0,
      lastUsedDate: _lastUsedDateController.text.isEmpty ? null : DateTime.parse(_lastUsedDateController.text),
      photoUrls: widget.equipmentItem?.photoUrls ?? const [],
      archivedAt: widget.equipmentItem?.archivedAt,
      archivedBy: widget.equipmentItem?.archivedBy,
      archivedReason: widget.equipmentItem?.archivedReason,
    );

    try {
      if (isCreating) {
        await ApiService.createEquipmentItem(equipmentItem);
      } else {
        await ApiService.updateEquipmentItem(widget.itemId!, equipmentItem);
      }
      ref.invalidate(allEquipmentItemsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isCreating ? 'Элемент создан' : 'Элемент обновлен'), backgroundColor: Colors.green,));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  void _navigateToMaintenanceHistoryEditScreen({EquipmentMaintenanceHistory? record}) async {
    if (widget.itemId == null) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EquipmentMaintenanceHistoryEditScreen(
          equipmentItemId: widget.itemId!,
          historyRecord: record,
        ),
      ),
    );
    if (result == true && mounted) {
      ref.invalidate(maintenanceHistoryProvider(widget.itemId!));
    }
  }

  Widget _buildMainInfoTab() {
    final equipmentTypesAsync = ref.watch(allEquipmentTypesProvider);
    final roomsAsync = ref.watch(allRoomsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          equipmentTypesAsync.when(
            data: (types) {
              if (_selectedEquipmentType == null && _initialEquipmentTypeId != null) {
                _selectedEquipmentType = types.firstWhereOrNull((type) => type.id == _initialEquipmentTypeId);
              }
              return DropdownButtonFormField<EquipmentType>(
                decoration: const InputDecoration(labelText: 'Тип оборудования', border: OutlineInputBorder()),
                initialValue: _selectedEquipmentType,
                items: types.map((type) => DropdownMenuItem(value: type, child: Text(type.name))).toList(),
                onChanged: (value) => setState(() => _selectedEquipmentType = value),
                validator: (value) => value == null ? 'Пожалуйста, выберите тип' : null,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Ошибка: $err'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _inventoryNumberController,
            decoration: const InputDecoration(labelText: 'Инвентарный номер', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _serialNumberController, decoration: const InputDecoration(labelText: 'Серийный номер', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: 'Модель', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextFormField(controller: _manufacturerController, decoration: const InputDecoration(labelText: 'Производитель', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          roomsAsync.when(
            data: (rooms) {
              if (_selectedRoom == null && _initialRoomId != null) {
                _selectedRoom = rooms.firstWhereOrNull((room) => room.id == _initialRoomId);
              }
              return DropdownButtonFormField<Room>(
                decoration: const InputDecoration(labelText: 'Помещение', border: OutlineInputBorder()),
                initialValue: _selectedRoom,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Не назначено')),
                  ...rooms.map((room) => DropdownMenuItem(value: room, child: Text(room.name))),
                ],
                onChanged: (value) => setState(() => _selectedRoom = value),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Ошибка: $err'),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _placementNoteController, decoration: const InputDecoration(labelText: 'Местоположение/Примечания', border: OutlineInputBorder())),
        ],
      ),
    );
  }

  Widget _buildConditionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EquipmentStatus>(
            decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),
            initialValue: _selectedStatus,
            items: EquipmentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
            onChanged: (v) => setState(() => _selectedStatus = v!),
            validator: (v) => v == null ? 'Обязательное поле' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Оценка состояния (1-5)', border: OutlineInputBorder()),
            initialValue: _conditionRating,
            items: List.generate(5, (i) => i + 1).map((r) => DropdownMenuItem(value: r, child: Text('$r'))).toList(),
            onChanged: (v) => setState(() => _conditionRating = v!),
             validator: (v) => v == null ? 'Обязательное поле' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _conditionNotesController, decoration: const InputDecoration(labelText: 'Заметки о состоянии', border: OutlineInputBorder()), maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildAccountingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _purchaseDateController,
            decoration: InputDecoration(labelText: 'Дата покупки', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _purchaseDateController))),
            readOnly: true,
            onTap: () => _selectDate(context, _purchaseDateController),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _purchasePriceController, decoration: const InputDecoration(labelText: 'Цена покупки', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 16),
          TextFormField(controller: _supplierController, decoration: const InputDecoration(labelText: 'Поставщик', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextFormField(controller: _warrantyMonthsController, decoration: const InputDecoration(labelText: 'Гарантия (мес.)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          TextFormField(controller: _usageHoursController, decoration: const InputDecoration(labelText: 'Часы использования', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
           TextFormField(
            controller: _lastUsedDateController,
            decoration: InputDecoration(labelText: 'Дата последнего использования', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context, _lastUsedDateController))),
            readOnly: true,
            onTap: () => _selectDate(context, _lastUsedDateController),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryTab() {
    final itemId = widget.itemId;
    if (itemId == null) {
      return const Center(child: Text('История обслуживания доступна после создания.'));
    }
    final historyAsync = ref.watch(maintenanceHistoryProvider(itemId));
    return Scaffold(
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('Нет записей в истории обслуживания.'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(record.descriptionOfWork),
                  subtitle: Text('Отправлено: ${record.dateSent.toLocal().toString().substring(0, 10)}'),
                  trailing: record.cost != null ? Text('${record.cost} руб.') : null,
                  onTap: () => _navigateToMaintenanceHistoryEditScreen(record: record),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Ошибка: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToMaintenanceHistoryEditScreen(),
        tooltip: 'Добавить запись',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemId == null ? 'Создать элемент' : 'Редактировать элемент'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
            tooltip: 'Сохранить',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Основное'),
            Tab(text: 'Состояние'),
            Tab(text: 'Учет'),
            Tab(text: 'История ТО'),
          ],
        ),
      ),
      body: _isLoading && widget.itemId != null && widget.equipmentItem == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMainInfoTab(),
                  _buildConditionTab(),
                  _buildAccountingTab(),
                  _buildMaintenanceHistoryTab(),
                ],
              ),
            ),
    );
  }
}