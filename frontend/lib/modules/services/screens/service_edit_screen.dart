import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';
import '../providers/catalog_provider.dart';

/// Создание и редактирование позиции каталога услуг.
class ServiceEditScreen extends ConsumerStatefulWidget {
  const ServiceEditScreen({super.key, this.service});

  final Service? service;

  @override
  ConsumerState<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends ConsumerState<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationDaysController;
  late final TextEditingController _durationMinutesController;
  late final TextEditingController _maxUsesController;
  late final TextEditingController _quotaLimitController;

  String? _serviceTypeId;
  String? _specializationId;
  int _usageLimitMode = ServiceUsageLimitMode.total;
  int _quotaPeriod = ServiceQuotaPeriod.month;
  bool _activationRequired = false;
  bool _allowStacking = true;
  bool _grantsAccess = true;
  bool _isActive = true;
  bool _saving = false;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _codeController = TextEditingController(text: service?.code ?? '');
    _nameController = TextEditingController(text: service?.name ?? '');
    _descriptionController =
        TextEditingController(text: service?.description ?? '');
    _priceController = TextEditingController(
      text: service?.basePrice == null ? '' : _plainNumber(service!.basePrice!),
    );
    _durationDaysController = TextEditingController(
      text: service?.durationDays?.toString() ?? '',
    );
    _durationMinutesController = TextEditingController(
      text: service?.durationMinutes?.toString() ?? '',
    );
    _maxUsesController = TextEditingController(
      text: service?.maxUses?.toString() ?? '',
    );
    _quotaLimitController = TextEditingController(
      text: service?.quotaLimit?.toString() ?? '',
    );

    _serviceTypeId = service?.serviceTypeId;
    _specializationId = service?.executorSpecializationId;
    _usageLimitMode = service?.usageLimitMode ?? ServiceUsageLimitMode.total;
    _quotaPeriod = service?.quotaPeriod ?? ServiceQuotaPeriod.month;
    _activationRequired = service?.activationRequired ?? false;
    _allowStacking = service?.allowStacking ?? true;
    _grantsAccess = service?.grantsAccess ?? true;
    _isActive = service?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationDaysController.dispose();
    _durationMinutesController.dispose();
    _maxUsesController.dispose();
    _quotaLimitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_serviceTypeId == null) {
      _showError('Выберите тип услуги');
      return;
    }

    setState(() => _saving = true);
    try {
      final payload = _buildPayload();
      final api = ServicesApiService();
      if (_isEdit) {
        await api.updateService(widget.service!.id, payload);
      } else {
        await api.createService(payload);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Не удалось сохранить: $error');
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'code': _codeController.text.trim(),
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'serviceTypeId': _serviceTypeId,
      'basePrice': _parseDouble(_priceController.text),
      'currency': 'RUB',
      'durationDays': _parseInt(_durationDaysController.text),
      'durationMinutes': _parseInt(_durationMinutesController.text),
      'usageLimitMode': _usageLimitMode,
      'maxUses': _usageLimitMode == ServiceUsageLimitMode.unlimited
          ? null
          : _parseInt(_maxUsesController.text),
      'quotaPeriod':
          _usageLimitMode == ServiceUsageLimitMode.quota ? _quotaPeriod : null,
      'quotaLimit': _usageLimitMode == ServiceUsageLimitMode.quota
          ? _parseInt(_quotaLimitController.text)
          : null,
      'executorSpecializationId': _specializationId,
      'activationRequired': _activationRequired,
      'allowStacking': _allowStacking,
      'grantsAccess': _grantsAccess,
      'isActive': _isActive,
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(serviceTypesProvider);
    final specializationsAsync = ref.watch(serviceSpecializationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Изменить услугу' : 'Новая услуга'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: 'Основное',
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Код услуги *',
                    hintText: 'MS-060',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Укажите код'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Укажите название'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                typesAsync.when(
                  data: (types) => DropdownButtonFormField<String>(
                    key: ValueKey(_serviceTypeId),
                    initialValue: _serviceTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Тип услуги *',
                      border: OutlineInputBorder(),
                    ),
                    items: types
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type['id'] as String,
                            child: Text(
                              type['title'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _serviceTypeId = value),
                    validator: (value) =>
                        value == null ? 'Выберите тип услуги' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stackTrace) =>
                      const Text('Не удалось загрузить типы услуг'),
                ),
                const SizedBox(height: 12),
                specializationsAsync.when(
                  data: (items) => DropdownButtonFormField<String?>(
                    key: ValueKey(_specializationId),
                    initialValue: _specializationId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Специализация исполнителя',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Без специализации'),
                      ),
                      ...items.map(
                        (item) => DropdownMenuItem<String?>(
                          value: item['id'] as String,
                          child: Text(
                            item['title'] as String,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _specializationId = value),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stackTrace) =>
                      const Text('Не удалось загрузить специализации'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Стоимость и срок',
              children: [
                TextFormField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Стоимость, ₽',
                    hintText: 'Пусто — без стоимости',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validatePositiveNumber(
                    value,
                    allowZero: true,
                    field: 'Стоимость',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationDaysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Срок, дней',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _validatePositiveInt(
                          value,
                          field: 'Срок',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _durationMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Сеанс, минут',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => _validatePositiveInt(
                          value,
                          field: 'Длительность',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Ограничение доступа',
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _usageLimitMode,
                  decoration: const InputDecoration(
                    labelText: 'Режим ограничения',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<int>(
                      value: ServiceUsageLimitMode.unlimited,
                      child: Text('Безлимит'),
                    ),
                    DropdownMenuItem<int>(
                      value: ServiceUsageLimitMode.total,
                      child: Text('Общий лимит использований'),
                    ),
                    DropdownMenuItem<int>(
                      value: ServiceUsageLimitMode.quota,
                      child: Text('Квота на период'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _usageLimitMode = value);
                    }
                  },
                ),
                if (_usageLimitMode == ServiceUsageLimitMode.total) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _maxUsesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Количество использований *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => _validatePositiveInt(
                      value,
                      field: 'Количество использований',
                      required: true,
                    ),
                  ),
                ],
                if (_usageLimitMode == ServiceUsageLimitMode.quota) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _quotaPeriod,
                          decoration: const InputDecoration(
                            labelText: 'Период квоты',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem<int>(
                              value: ServiceQuotaPeriod.day,
                              child: Text('День'),
                            ),
                            DropdownMenuItem<int>(
                              value: ServiceQuotaPeriod.week,
                              child: Text('Неделя'),
                            ),
                            DropdownMenuItem<int>(
                              value: ServiceQuotaPeriod.month,
                              child: Text('Месяц'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _quotaPeriod = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _quotaLimitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Лимит периода *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => _validatePositiveInt(
                            value,
                            field: 'Лимит периода',
                            required: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Правила',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Активация вручную'),
                  subtitle:
                      const Text('Покупка создаётся черновиком и ждёт активации'),
                  value: _activationRequired,
                  onChanged: (value) =>
                      setState(() => _activationRequired = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Разрешить несколько покупок'),
                  subtitle: const Text(
                    'Если выключено, вторую действующую покупку оформить нельзя',
                  ),
                  value: _allowStacking,
                  onChanged: (value) => setState(() => _allowStacking = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Даёт право доступа'),
                  subtitle:
                      const Text('Выключено для сборов и подарочных документов'),
                  value: _grantsAccess,
                  onChanged: (value) => setState(() => _grantsAccess = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Активна в каталоге'),
                  subtitle: const Text('Снятая с продажи остаётся в истории'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Сохранить' : 'Создать услугу'),
            ),
          ],
        ),
      ),
    );
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  String? _validatePositiveInt(
    String? value, {
    required String field,
    bool required = false,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return required ? 'Укажите $field' : null;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return '$field должно быть больше нуля';
    }
    return null;
  }

  String? _validatePositiveNumber(
    String? value, {
    required String field,
    bool allowZero = false,
  }) {
    final trimmed = value?.trim().replaceAll(',', '.') ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0 || (!allowZero && parsed == 0)) {
      return '$field указана неверно';
    }
    return null;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

String _plainNumber(double value) {
  return value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toString();
}
