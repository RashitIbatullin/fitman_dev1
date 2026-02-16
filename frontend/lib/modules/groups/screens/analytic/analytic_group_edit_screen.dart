import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import '../../models/analytic_group.model.dart';
import '../../models/group_condition.model.dart';
import 'package:intl/intl.dart';
import 'package:fitman_app/services/api_service.dart'; // Add this import

class AnalyticGroupEditScreen extends ConsumerStatefulWidget {
  final String? groupId;
  const AnalyticGroupEditScreen({super.key, this.groupId});

  @override
  ConsumerState<AnalyticGroupEditScreen> createState() => _AnalyticGroupEditScreenState();
}

class _AnalyticGroupEditScreenState extends ConsumerState<AnalyticGroupEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final int? _groupId;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  AnalyticGroupType? _selectedType;
  bool _isAutoUpdate = false;
  List<GroupCondition> _conditions = [];
  bool _isArchived = false; // New state for archived status

  AnalyticGroup? _initialGroup;

  @override
  void initState() {
    super.initState();
    _groupId = widget.groupId != null ? int.tryParse(widget.groupId!) : null;
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    if (_groupId != null) {
      _loadGroupData();
    }
  }

  Future<void> _loadGroupData() async {
    try {
      final group = await ApiService.getAnalyticGroupById(_groupId!); // Use API service directly
      if (!mounted) return; // Add check
      setState(() {
        _initialGroup = group;
        _nameController.text = group.name;
        _descriptionController.text = group.description ?? '';
        _selectedType = group.type;
        _isAutoUpdate = group.isAutoUpdate;
        _conditions = List.from(group.conditions);
        _isArchived = group.archivedAt != null; // Set archived status
      });
    } catch (e) {
      print('Failed to load group data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGroup = AnalyticGroup(
        id: _groupId,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        type: _selectedType!,
        isAutoUpdate: _isAutoUpdate,
        conditions: _isAutoUpdate ? _conditions : [],
        clientIds: _initialGroup?.clientIds ?? [],
        lastUpdatedAt: _initialGroup?.lastUpdatedAt,
        archivedAt: _isArchived ? (_initialGroup?.archivedAt ?? DateTime.now()) : null, // Set archivedAt
      );

      try {
        if (_groupId == null) {
          // Create new group
          await ref.read(analyticGroupsProvider(searchQuery: '', isArchived: null).notifier).createAnalyticGroup(newGroup);
        } else {
          // Update existing group
          await ref.read(analyticGroupsProvider(searchQuery: '', isArchived: null).notifier).updateAnalyticGroup(newGroup);
        }
        if (!mounted) return; // Add check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа успешно сохранена!')),
        );
        if (!mounted) return; // Add check
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return; // Add check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения группы: $e')),
        );
      }
    }
  }

  String _analyticGroupTypeToString(AnalyticGroupType type) {
    switch (type) {
      case AnalyticGroupType.corporate: return 'Корпоративная';
      case AnalyticGroupType.demographic: return 'Демографическая';
      case AnalyticGroupType.financial: return 'Финансовая';
      case AnalyticGroupType.behavioral: return 'Поведенческая';
      case AnalyticGroupType.custom: return 'Произвольная';
    }
  }

  List<DropdownMenuItem<String>> _getOperatorsForField(String field) {
    switch (field) {
      case 'age':
      case 'last_visit_date':
        return const [
          DropdownMenuItem(value: 'equals', child: Text('=')),
          DropdownMenuItem(value: 'greater_than', child: Text('>')),
          DropdownMenuItem(value: 'less_than', child: Text('<')),
        ];
      case 'gender':
      case 'subscription_type':
        return const [
          DropdownMenuItem(value: 'equals', child: Text('=')),
        ];
      default:
        return const [
          DropdownMenuItem(value: 'equals', child: Text('=')),
          DropdownMenuItem(value: 'contains', child: Text('содержит')),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupId == null ? 'Создать аналитическую группу' : 'Редактировать аналитическую группу'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название группы'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              DropdownButtonFormField<AnalyticGroupType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип группы'),
                items: AnalyticGroupType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_analyticGroupTypeToString(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    _isAutoUpdate = value != AnalyticGroupType.custom; // Custom groups are manual
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Пожалуйста, выберите тип группы';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Автоматическое обновление'),
                value: _isAutoUpdate,
                onChanged: _selectedType == AnalyticGroupType.custom // Custom groups cannot be auto-updated
                    ? null
                    : (value) {
                        setState(() {
                          _isAutoUpdate = value;
                        });
                      },
              ),
              SwitchListTile(
                title: const Text('В архиве'),
                value: _isArchived,
                onChanged: (value) {
                  setState(() {
                    _isArchived = value;
                  });
                },
              ),
              if (_isAutoUpdate) ...[
                const Divider(),
                Text('Условия для автоматического обновления', style: Theme.of(context).textTheme.titleMedium),
                ..._conditions.map((condition) => _buildConditionRow(condition)), // Removed .toList()
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить условие'),
                    onPressed: () {
                      setState(() {
                        _conditions.add(const GroupCondition(field: '', operator: 'equals', value: ''));
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // TODO: Implement metadata editing if needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionRow(GroupCondition condition) {
    int index = _conditions.indexOf(condition);

    List<DropdownMenuItem<String>> getOperatorsForField(String field) {
      switch (field) {
        case 'age':
        case 'last_visit_date':
          return const [
            DropdownMenuItem(value: 'equals', child: Text('=')),
            DropdownMenuItem(value: 'greater_than', child: Text('>')),
            DropdownMenuItem(value: 'less_than', child: Text('<')),
          ];
        case 'gender':
        case 'subscription_type':
          return const [
            DropdownMenuItem(value: 'equals', child: Text('=')),
          ];
        default:
          return const [
            DropdownMenuItem(value: 'equals', child: Text('=')),
            DropdownMenuItem(value: 'contains', child: Text('содержит')),
          ];
      }
    }
    
    final operatorItems = _getOperatorsForField(condition.field);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: condition.field.isEmpty ? null : condition.field,
              decoration: const InputDecoration(labelText: 'Поле'),
              items: const [
                DropdownMenuItem(value: 'age', child: Text('Возраст')),
                DropdownMenuItem(value: 'gender', child: Text('Пол')),
                DropdownMenuItem(value: 'subscription_type', child: Text('Тип абонемента')),
                DropdownMenuItem(value: 'last_visit_date', child: Text('Дата посл. визита')),
              ],
              onChanged: (value) => setState(() {
                final newOperator = getOperatorsForField(value!).first.value!;
                _conditions[index] = _conditions[index].copyWith(field: value, value: '', operator: newOperator);
              }),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Выберите поле';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: condition.operator,
              decoration: const InputDecoration(labelText: 'Оператор'),
              items: operatorItems,
              onChanged: (value) => setState(() {
                _conditions[index] = _conditions[index].copyWith(operator: value!);
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _buildValueWidget(condition, index),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _conditions.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueWidget(GroupCondition condition, int index) {
    switch (condition.field) {
      case 'gender':
        return DropdownButtonFormField<String>(
          initialValue: condition.value.isEmpty ? null : condition.value,
          decoration: const InputDecoration(labelText: 'Значение'),
          items: const [
            DropdownMenuItem(value: 'мужской', child: Text('Мужской')),
            DropdownMenuItem(value: 'женский', child: Text('Женский')),
          ],
          onChanged: (value) {
            setState(() {
              _conditions[index] = _conditions[index].copyWith(value: value!);
            });
          },
        );
      case 'subscription_type':
        // TODO: Fetch subscription types from a catalog
        return DropdownButtonFormField<String>(
          initialValue: condition.value.isEmpty ? null : condition.value,
          decoration: const InputDecoration(labelText: 'Значение'),
          items: const [
            DropdownMenuItem(value: 'standard', child: Text('Стандарт')),
            DropdownMenuItem(value: 'premium', child: Text('Премиум')),
            DropdownMenuItem(value: 'annual', child: Text('Годовой')),
          ],
          onChanged: (value) {
            setState(() {
              _conditions[index] = _conditions[index].copyWith(value: value!);
            });
          },
        );
      case 'last_visit_date':
        return InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(condition.value) ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _conditions[index] = _conditions[index].copyWith(value: pickedDate.toIso8601String().substring(0, 10));
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Значение',
            ),
            child: Text(
              condition.value.isEmpty ? 'Выберите дату' : DateFormat('dd.MM.yyyy').format(DateTime.parse(condition.value)),
            ),
          ),
        );
      default: // age, etc.
        return TextFormField(
          key: ValueKey(condition.field), // Ensure TextFormField rebuilds when field changes
          initialValue: condition.value,
          decoration: const InputDecoration(labelText: 'Значение'),
          onChanged: (value) => _conditions[index] = _conditions[index].copyWith(value: value),
        );
    }
  }
}