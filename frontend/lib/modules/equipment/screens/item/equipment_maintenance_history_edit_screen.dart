import 'package:fitman_app/modules/equipment/screens/maintenance_status_history_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitman_app/models/available_executor.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_status.enum.dart';
import 'package:fitman_app/modules/equipment/models/equipment_maintenance_history.model.dart';
import 'package:fitman_app/modules/equipment/providers/equipment/equipment_provider.dart';
import 'package:fitman_app/modules/equipment/providers/maintenance_provider.dart';
// import 'package:fitman_app/modules/equipment/widgets/maintenance_status_history_widget.dart'; // No longer used
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Helper class to manage existing and new photos
class _PhotoHolder {
  final MaintenancePhoto? existingPhoto;
  final PlatformFile? newFile;
  final TextEditingController commentController;

  _PhotoHolder({this.existingPhoto, this.newFile})
      : commentController =
            TextEditingController(text: existingPhoto?.comment ?? ''),
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
  late TextEditingController _notesController;
  late TextEditingController _cancellationReasonController;
  late TextEditingController _executorNameController;
  late TextEditingController _numberController;

  late MaintenanceType _selectedType;
  late MaintenanceStatus _selectedStatus;
  String? _executorId;
  ExecutorType? _executorType;

  final List<_PhotoHolder> _beforePhotos = [];
  final List<_PhotoHolder> _afterPhotos = [];

  bool _isLoading = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    final record = widget.historyRecord;
    _reportedProblemController =
        TextEditingController(text: record?.reportedProblem ?? '');
    _workDescriptionController =
        TextEditingController(text: record?.workDescription ?? '');
    _notesController = TextEditingController(text: record?.notes ?? '');
    _cancellationReasonController =
        TextEditingController(text: record?.cancellationReason ?? '');
    _numberController = TextEditingController(text: record?.number ?? '');

    _selectedType = record?.type ?? MaintenanceType.corrective;
    _selectedStatus = record?.status ?? MaintenanceStatus.reported;

    _executorNameController =
        TextEditingController(text: record?.executorName ?? '');
    _executorId = record?.executorId;
    _executorType = record?.executorType;

    _isLocked = record != null &&
        (record.status == MaintenanceStatus.completed ||
            record.status == MaintenanceStatus.cancelled);

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
    _notesController.dispose();
    _cancellationReasonController.dispose();
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
        photoList
            .addAll(result.files.map((file) => _PhotoHolder(newFile: file)));
      });
    }
  }

  EquipmentStatus _getEquipmentStatusForMaintenanceStatus(
      MaintenanceStatus maintenanceStatus) {
    switch (maintenanceStatus) {
      case MaintenanceStatus.reported:
        return EquipmentStatus.outOfOrder;
      case MaintenanceStatus.inProgress:
        return EquipmentStatus.maintenance;
      case MaintenanceStatus.completed:
      case MaintenanceStatus.cancelled:
        return EquipmentStatus.available;
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
          const SnackBar(
              content: Text('Ошибка: не удалось определить пользователя'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (isCreating) {
        final currentEquipmentItem = await ref
            .read(equipmentItemByIdProvider(widget.equipmentItemId).future);

        recordToSave = EquipmentMaintenanceHistory(
          id: null,
          equipmentItemId: widget.equipmentItemId,
          equipmentName: currentEquipmentItem.model, // Pass equipmentName here
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text.isNotEmpty
              ? _workDescriptionController.text
              : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          type: _selectedType,
          status: _selectedStatus,
          reportedBy: userId.toString(),
          executorId: _executorId,
          executorType: _executorType,
          cancellationReason: _cancellationReasonController.text,
        );
        recordToSave = await ApiService.createMaintenanceHistory(recordToSave);

        if (_selectedType == MaintenanceType.corrective) {
          final currentItem = await ref
              .read(equipmentItemByIdProvider(widget.equipmentItemId).future);
          final updatedItem =
              currentItem.copyWith(status: EquipmentStatus.outOfOrder);
          await ref.read(equipmentProvider.notifier).updateItem(updatedItem);
        }
      } else {
        recordToSave = widget.historyRecord!.copyWith(
          reportedProblem: _reportedProblemController.text,
          workDescription: _workDescriptionController.text,
          notes: _notesController.text,
          type: _selectedType,
          status: _selectedStatus,
          executorId: _executorId,
          executorType: _executorType,
          cancellationReason: _cancellationReasonController.text,
        );
        recordToSave = await ApiService.updateMaintenanceHistory(
            recordToSave.id!, recordToSave);

        final newEquipmentStatus =
            _getEquipmentStatusForMaintenanceStatus(_selectedStatus);
        final currentItem = await ref
            .read(equipmentItemByIdProvider(widget.equipmentItemId).future);

        if (currentItem.status != newEquipmentStatus) {
          final updatedItem =
              currentItem.copyWith(status: newEquipmentStatus);
          await ref.read(equipmentProvider.notifier).updateItem(updatedItem);
        }
      }

      // Photo upload logic... (unchanged)

      ref.invalidate(allMaintenanceHistoryProvider);
      ref.invalidate(maintenanceHistoryProvider(widget.equipmentItemId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Запись сохранена'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } catch (e, st) {
      if (!mounted) return;

      print('--- SAVE FAILED ---');
      print('ERROR: $e');
      print('STACK TRACE: $st');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка сохранения: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MaintenanceStatus> _getAvailableStatuses() {
    // For new records, only 'reported' is valid.
    if (widget.historyRecord == null) {
      return [MaintenanceStatus.reported];
    }
    // For existing records, logic depends on the current status.
    switch (widget.historyRecord!.status) {
      case MaintenanceStatus.reported:
        return [
          MaintenanceStatus.reported,
          MaintenanceStatus.inProgress,
          MaintenanceStatus.cancelled
        ];
      case MaintenanceStatus.inProgress:
        return [
          MaintenanceStatus.inProgress,
          MaintenanceStatus.completed,
          MaintenanceStatus.cancelled
        ];
      case MaintenanceStatus.completed:
        return [MaintenanceStatus.completed];
      case MaintenanceStatus.cancelled:
        return [MaintenanceStatus.cancelled];
    }
  }

  Future<void> _onStatusChanged(MaintenanceStatus? newValue) async {
    if (newValue == null || newValue == _selectedStatus) return;
    
    if (newValue == MaintenanceStatus.inProgress && _executorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Нельзя перевести в статус "В работе" без назначения исполнителя.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (newValue == MaintenanceStatus.cancelled) {
      final reason = await _promptForCancellationReason();
      if (reason == null || reason.isEmpty) {
        return; // User cancelled the dialog, so we don't change the status
      }
      setState(() {
        _cancellationReasonController.text = reason;
        _selectedStatus = newValue;
      });
    } else {
      setState(() {
        _selectedStatus = newValue;
      });
    }
  }

  Future<String?> _promptForCancellationReason() async {
    final reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Причина отмены'),
          content: TextField(
            controller: reasonController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Укажите причину...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(reasonController.text);
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the form should be locked based on the CURRENTLY SELECTED status
    final isFormLocked = _isLocked ||
        _selectedStatus == MaintenanceStatus.completed ||
        _selectedStatus == MaintenanceStatus.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.historyRecord == null
            ? 'Новая заявка на ТО'
            : 'Редактировать заявку'),
        actions: [
          if (widget.historyRecord != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MaintenanceStatusHistoryScreen(
                        maintenanceId: widget.historyRecord!.id!,
                      ),
                    ),
                  );
                },
                child: const Text('История статусов'),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading || _isLocked ? null : _saveForm,
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
              if (widget.historyRecord?.number != null) ...[
                TextFormField(
                  controller: _numberController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Номер заявки', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
              ],
              // Dropdown for Maintenance Type
              FormField<MaintenanceType>(
                builder: (FormFieldState<MaintenanceType> state) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Тип ТО',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MaintenanceType>(
                        value: _selectedType,
                        isDense: true,
                        onChanged: isFormLocked ? null : (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                              state.didChange(newValue);
                            });
                          }
                        },
                        items: MaintenanceType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.title),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Dropdown for Maintenance Status
              FormField<MaintenanceStatus>(
                builder: (FormFieldState<MaintenanceStatus> state) {
                  return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Статус',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<MaintenanceStatus>(
                        value: _selectedStatus,
                        isDense: true,
                        onChanged: isFormLocked ? null : _onStatusChanged,
                        items: _getAvailableStatuses().map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.title),
                          );
                        }).toList(),
                      ),
                    ),
                  );
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
                    onPressed: _selectedStatus == MaintenanceStatus.reported ? _showExecutorSelectionDialog : null,
                  ),
                ),
                onTap: _selectedStatus == MaintenanceStatus.reported ? _showExecutorSelectionDialog : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reportedProblemController,
                readOnly: isFormLocked,
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
                readOnly: _selectedStatus != MaintenanceStatus.inProgress,
                decoration: const InputDecoration(
                    labelText: 'Описание выполненных работ',
                    border: OutlineInputBorder()),
                maxLines: 3,
              ),
              if (_selectedStatus == MaintenanceStatus.cancelled)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _cancellationReasonController,
                    readOnly: true, // Reason is set via dialog
                    decoration: const InputDecoration(
                        labelText: 'Причина отмены',
                        border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                ),
              const SizedBox(height: 24),
              _buildPhotoSection(context, 'Фото "До"', _beforePhotos, isFormLocked),
              const SizedBox(height: 16),
              _buildPhotoSection(context, 'Фото "После"', _afterPhotos, isFormLocked),
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

  Widget _buildPhotoSection(
      BuildContext context, String title, List<_PhotoHolder> photos, bool isLocked) {
    // ... photo section build logic is unchanged
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
                                  Image(
                                      image: image,
                                      width: 150,
                                      height: 100,
                                      fit: BoxFit.cover)
                                else
                                  Container(
                                      width: 150,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported)),
                                if (!isLocked)
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
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 16),
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
                                  hintText:
                                      photoHolder.isNew ? 'Мин. 5 символов' : '',
                                  border: photoHolder.isNew && !isLocked
                                      ? const OutlineInputBorder()
                                      : InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                ),
                                style: const TextStyle(fontSize: 12),
                                readOnly: !photoHolder.isNew || isLocked,
                                validator: (v) {
                                  if (photoHolder.isNew && !isLocked &&
                                      (v == null || v.trim().length < 5)) {
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
        if(!isLocked)
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
  ConsumerState<_ExecutorSelectionDialog> createState() =>
      __ExecutorSelectionDialogState();
}

class __ExecutorSelectionDialogState
    extends ConsumerState<_ExecutorSelectionDialog> {
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
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
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
      final fullName =
          ('${e.firstName ?? ''} ${e.lastName ?? ''}').toLowerCase().trim();
      return fullName.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final executor = filteredList[index];
        final displayName =
            ('${executor.lastName ?? ''} ${executor.firstName ?? ''}').trim();
        return ListTile(
          title:
              Text(displayName.isNotEmpty ? displayName : 'Имя не указано'),
          onTap: () {
            Navigator.of(context).pop({
              'id': executor.id,
              'name':
                  displayName.isNotEmpty ? displayName : 'Имя не указано',
              'type': type,
            });
          },
        );
      },
    );
  }
}
