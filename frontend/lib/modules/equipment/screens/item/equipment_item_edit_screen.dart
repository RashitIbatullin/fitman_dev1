import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';
import 'package:fitman_app/modules/rooms/providers/room/room_provider.dart';
import 'package:fitman_common/fitman_common.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'equipment_maintenance_history_edit_screen.dart';
import 'package:fitman_app/modules/equipment/widgets/maintenance_list_tile.dart';
import 'package:fitman_app/modules/users/providers/users_provider.dart';


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

  String? _currentEquipmentId; // New state variable
  String? _initialEquipmentTypeId;
  String? _initialRoomId;
  EquipmentType? _selectedEquipmentType;
  Room? _selectedRoom;

  bool _isLoading = false;
  String? _inventoryNumberError;

  final List<PlatformFile> _stagedPhotos = []; // For new items, photos not yet uploaded
  final List<String> _stagedPhotoPaths = []; // To display locally picked images in carousel

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // <-- CHANGED from 5 to 4
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

    _currentEquipmentId = widget.itemId ?? widget.equipmentItem?.id; // Initialize _currentEquipmentId

    if (widget.equipmentItem != null) {
      _populateForm(widget.equipmentItem!);
    } else if (_currentEquipmentId != null) { // Use _currentEquipmentId here
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

  Future<void> _pickAndAddPhoto(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final platformFile = result.files.single;

      if (_currentEquipmentId == null) {
        // Creation mode: stage the photo
        setState(() {
          _stagedPhotos.add(platformFile);
          if (kIsWeb) {
            final dataUrl = 'data:image/jpeg;base64,${base64Encode(platformFile.bytes!)}';
            _stagedPhotoPaths.add(dataUrl);
          } else {
            _stagedPhotoPaths.add(platformFile.path!);
          }
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Фото добавлено в список')),
        );
      } else {
        // Editing mode: upload directly
        await _uploadPhoto(context, ref, _currentEquipmentId!, platformFile.bytes!, platformFile.name);
      }
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Выбор фото отменен или файл недоступен.')),
      );
    }
  }

  Future<void> _uploadPhoto(BuildContext context, WidgetRef ref, String equipmentId, Uint8List photoBytes, String fileName) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.uploadEquipmentPhoto(
        equipmentId: equipmentId,
        photoBytes: photoBytes,
        fileName: fileName,
      );
      ref.invalidate(equipmentItemByIdProvider(equipmentId));
      ref.invalidate(allEquipmentItemsProvider);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Фото успешно загружено')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка загрузки фото: $e')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить фото?'),
          content: const Text('Вы уверены, что хотите удалить это фото?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      final item = await ref.read(equipmentItemByIdProvider(_currentEquipmentId!).future);
      _populateForm(item);
    } catch (e) {
      if (!mounted) return;
       scaffoldMessenger.showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveForm() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!_formKey.currentState!.validate()) return;
    if (_selectedEquipmentType == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Пожалуйста, выберите тип оборудования.'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final isCreating = _currentEquipmentId == null;
    String? equipmentIdToSave = _currentEquipmentId;

    final equipmentItem = EquipmentItem(
      id: equipmentIdToSave ?? '',
      typeId: _selectedEquipmentType!.id,
      inventoryNumber: _inventoryNumberController.text,
      serialNumber: _serialNumberController.text.isEmpty
          ? null
          : _serialNumberController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
      manufacturer: _manufacturerController.text.isEmpty
          ? null
          : _manufacturerController.text,
      roomId: _selectedRoom?.id,
      placementNote: _placementNoteController.text.isEmpty
          ? null
          : _placementNoteController.text,
      status: _selectedStatus,
      conditionRating: _conditionRating,
      conditionNotes: _conditionNotesController.text.isEmpty
          ? null
          : _conditionNotesController.text,
      lastMaintenanceDate: _lastMaintenanceDateController.text.isEmpty
          ? null
          : DateTime.parse(_lastMaintenanceDateController.text),
      nextMaintenanceDate: _nextMaintenanceDateController.text.isEmpty
          ? null
          : DateTime.parse(_nextMaintenanceDateController.text),
      maintenanceNotes: _maintenanceNotesController.text.isEmpty
          ? null
          : _maintenanceNotesController.text,
      purchaseDate: _purchaseDateController.text.isEmpty
          ? null
          : DateTime.parse(_purchaseDateController.text),
      purchasePrice: _purchasePriceController.text.isEmpty
          ? null
          : double.tryParse(_purchasePriceController.text),
      supplier:
          _supplierController.text.isEmpty ? null : _supplierController.text,
      warrantyMonths: _warrantyMonthsController.text.isEmpty
          ? null
          : int.tryParse(_warrantyMonthsController.text),
      usageHours: int.tryParse(_usageHoursController.text) ?? 0,
      lastUsedDate: _lastUsedDateController.text.isEmpty
          ? null
          : DateTime.parse(_lastUsedDateController.text),
      photoUrls: isCreating ? const [] : widget.equipmentItem?.photoUrls ?? const [],
      archivedAt: widget.equipmentItem?.archivedAt,
      archivedBy: widget.equipmentItem?.archivedBy,
      archivedReason: widget.equipmentItem?.archivedReason,
    );

    try {
      if (isCreating) {
        final createdItem = await ApiService.createEquipmentItem(equipmentItem);
        equipmentIdToSave = createdItem.id; 

        for (final stagedPhoto in _stagedPhotos) {
          if (stagedPhoto.bytes != null) {
            await ApiService.uploadEquipmentPhoto(
              equipmentId: equipmentIdToSave,
              photoBytes: stagedPhoto.bytes!,
              fileName: stagedPhoto.name,
            );
          }
        }
      } else {
        if (equipmentIdToSave == null) {
          throw Exception("ID элемента оборудования не найдено для обновления.");
        }
        await ApiService.updateEquipmentItem(equipmentIdToSave, equipmentItem);
      }
      ref.invalidate(allEquipmentItemsProvider);
      ref.invalidate(equipmentItemByIdProvider(equipmentIdToSave));
      
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(isCreating ? 'Элемент создан' : 'Элемент обновлен'),
        backgroundColor: Colors.green,
      ));
      navigator.pop(true);
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('Инвентарный номер уже существует')) {
        setState(() {
          _inventoryNumberError = 'Этот номер уже используется';
        });
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Ошибка: $errorMessage'), backgroundColor: Colors.red));
      }
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
    final currentId = _currentEquipmentId;
    if (currentId == null) return;
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EquipmentMaintenanceHistoryEditScreen(
          equipmentItemId: currentId,
          historyRecord: record,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(maintenanceHistoryProvider(currentId));
    }
  }

  Widget _buildPhotosTab(BuildContext context, WidgetRef ref) {
    // ... (content remains the same)
        final isCreating = _currentEquipmentId == null;
    
    final photosToDisplay = isCreating ? _stagedPhotoPaths : <String>[];
    
    final itemAsync = isCreating ? null : ref.watch(equipmentItemByIdProvider(_currentEquipmentId!));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          if (isCreating) ...[
            if (photosToDisplay.isEmpty)
              const Center(
                child: Text(
                  'Нет фотографий (будут добавлены после сохранения)',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              CarouselSlider.builder(
                itemCount: photosToDisplay.length,
                itemBuilder: (context, index, realIndex) {
                  final photoPath = photosToDisplay[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                          child: photoPath.startsWith('data:image')
                              ? Image.network(
                                  photoPath,
                                  fit: BoxFit.cover,
                                  width: 1000,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error, color: Colors.red, size: 48),
                                )
                              : Image.file(
                                  File(photoPath),
                                  fit: BoxFit.cover,
                                  width: 1000,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error, color: Colors.red, size: 48),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _stagedPhotos.removeAt(index);
                              _stagedPhotoPaths.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Фото удалено из списка')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((0.7 * 255).round()),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  height: 400.0,
                  enlargeCenterPage: true,
                  autoPlay: photosToDisplay.length > 1,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: photosToDisplay.length > 1,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
              ),
          ] else ...[
            itemAsync!.when(
              data: (item) {
                if (item.photoUrls.isEmpty) {
                  return const Center(
                    child: Text(
                      'Нет фотографий',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                final baseUrl = ApiService.baseUrl;
                return CarouselSlider.builder(
                  itemCount: item.photoUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    final photoUrl = item.photoUrls[index];
                    final fullUrl = photoUrl.startsWith('http')
                        ? photoUrl
                        : '$baseUrl/${photoUrl.startsWith('/') ? photoUrl.substring(1) : photoUrl}';
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                            child: Image.network(
                              fullUrl,
                              fit: BoxFit.cover,
                              width: 1000,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, color: Colors.red, size: 48),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await _showDeleteConfirmationDialog(context);
                              if (confirm == true) {
                                try {
                                  await ApiService.removeEquipmentPhoto(
                                      equipmentId: _currentEquipmentId!, photoUrl: photoUrl);
                                  ref.invalidate(equipmentItemByIdProvider(_currentEquipmentId!));
                                  ref.invalidate(allEquipmentItemsProvider);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Фото успешно удалено')),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ошибка удаления фото: $e')),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha((0.7 * 255).round()),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 400.0,
                    enlargeCenterPage: true,
                    autoPlay: item.photoUrls.length > 1,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: item.photoUrls.length > 1,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    viewportFraction: 0.8,
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка загрузки фото: $error')),
            ),
          ],
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _pickAndAddPhoto(context, ref),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Добавить фото'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoTab() {
    final equipmentTypesAsync = ref.watch(allEquipmentTypesIncludingArchivedProvider);
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
            decoration: InputDecoration(
              labelText: 'Инвентарный номер',
              border: const OutlineInputBorder(),
              errorText: _inventoryNumberError,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
            onChanged: (value) {
              if (_inventoryNumberError != null) {
                setState(() {
                  _inventoryNumberError = null;
                });
              }
            },
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
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _EquipmentConditionSection(
            selectedStatus: _selectedStatus,
            conditionRating: _conditionRating,
            conditionNotesController: _conditionNotesController,
            onStatusChanged: (status) {
              if(status != null) {
                setState(() => _selectedStatus = status);
              }
            },
            onRatingChanged: (rating) {
               if(rating != null) {
                setState(() => _conditionRating = rating);
               }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountingTab() {
    // ... (content remains the same)
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
    // ... (content remains the same as the full-featured one)
    final itemId = _currentEquipmentId;
    if (itemId == null) {
      return const Center(child: Text('История обслуживания доступна после создания.'));
    }
    final historyAsync = ref.watch(maintenanceHistoryProvider(itemId));
    final showArchived = ref.watch(maintenanceHistoryFilterIncludeArchivedProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Архив'),
                Switch(
                  value: showArchived,
                  onChanged: (value) {
                    ref.read(maintenanceHistoryFilterIncludeArchivedProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return const Center(child: Text('Нет записей в истории обслуживания.'));
                }
                history.sort((a, b) {
                  if (a.createdAt == null && b.createdAt == null) return 0;
                  if (a.createdAt == null) return 1;
                  if (b.createdAt == null) return -1;
                  return b.createdAt!.compareTo(a.createdAt!);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    final isArchived = record.archivedAt != null;

                    return MaintenanceListTile(
                      historyItem: record,
                      statusDetails: isArchived
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Архивировано', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                                  _buildInfoRow(context, 'Когда:', record.archivedAt?.toLocal().toString().substring(0, 10) ?? 'N/A'),
                                  ArchivedByInfo(userId: record.archivedBy, isSmall: true),
                                  _buildInfoRow(context, 'Причина:', record.archivedReason ?? 'N/A'),
                                ],
                              ),
                            )
                          : null,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _navigateToMaintenanceHistoryEditScreen(record: record);
                          } else if (value == 'archive') {
                            _showArchiveDialog(context, ref, record);
                          } else if (value == 'unarchive') {
                            ref.read(maintenanceProvider.notifier).unarchiveMaintenanceHistory(record.id!, record.equipmentItemId);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          if (!isArchived) ...[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Редактировать'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'archive',
                              child: Text('Архивировать'),
                            ),
                          ] else ...[
                            const PopupMenuItem<String>(
                              value: 'unarchive',
                              child: Text('Деархивировать'),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Ошибка: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToMaintenanceHistoryEditScreen(),
        tooltip: 'Добавить запись',
        child: const Icon(Icons.add),
      ),
    );
  }
  // ... new helper methods ...
  void _showArchiveDialog(BuildContext context, WidgetRef ref, EquipmentMaintenanceHistory record) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validate() {
              setState(() {
                formKey.currentState?.validate();
              });
            }

            reasonController.addListener(validate);

            return AlertDialog(
              title: const Text('Архивировать запись'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: reasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Причина архивации',
                    hintText: 'Минимум 5 символов',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Причина должна быть не менее 5 символов.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    reasonController.removeListener(validate);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: formKey.currentState?.validate() ?? false
                      ? () {
                          ref.read(maintenanceProvider.notifier).archiveMaintenanceHistory(
                                record.id!,
                                record.equipmentItemId,
                                reasonController.text.trim(),
                              );
                          reasonController.removeListener(validate);
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Архивировать'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = widget.itemId == null && widget.equipmentItem == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isCreating ? 'Создать элемент' : 'Редактировать элемент'),
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
            Tab(text: 'Фото'),
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
                  _buildPhotosTab(context, ref),
                  _buildAccountingTab(),
                  _buildMaintenanceHistoryTab(),
                ],
              ),
            ),
    );
  }
}

class _EquipmentConditionSection extends StatelessWidget {
  final EquipmentStatus selectedStatus;
  final int conditionRating;
  final TextEditingController conditionNotesController;
  final ValueChanged<EquipmentStatus?> onStatusChanged;
  final ValueChanged<int?> onRatingChanged;

  const _EquipmentConditionSection({
    required this.selectedStatus,
    required this.conditionRating,
    required this.conditionNotesController,
    required this.onStatusChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Состояние', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<EquipmentStatus>(
          decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),
          initialValue: selectedStatus,
          items: EquipmentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
          onChanged: onStatusChanged,
          validator: (v) => v == null ? 'Обязательное поле' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: 'Оценка состояния (1-5)', border: OutlineInputBorder()),
          initialValue: conditionRating,
          items: List.generate(5, (i) => i + 1).map((r) => DropdownMenuItem(value: r, child: Text('$r'))).toList(),
          onChanged: onRatingChanged,
          validator: (v) => v == null ? 'Обязательное поле' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: conditionNotesController,
          decoration: const InputDecoration(labelText: 'Заметки о состоянии', border: OutlineInputBorder()),
          maxLines: 3,
        ),
      ],
    );
  }
}

// ... helper widgets for maintenance history ...
Widget _buildDetailRow({
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}

class ArchivedByInfo extends ConsumerWidget {
  const ArchivedByInfo({super.key, this.userId, this.isSmall = false});

  final String? userId;
  final bool isSmall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return _buildRow(context, 'Кто:', 'N/A');
    }

    final userAsync = ref.watch(userByIdProvider(userId!));

    return userAsync.when(
      data: (user) => _buildRow(context, 'Кто:', user.shortName),
      loading: () => _buildRow(context, 'Кто:', 'Загрузка...'),
      error: (err, stack) => _buildRow(context, 'Кто:', 'Ошибка'),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    if (isSmall) {
        return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      );
    }
    return _buildDetailRow(label: label, value: value);
  }
}
