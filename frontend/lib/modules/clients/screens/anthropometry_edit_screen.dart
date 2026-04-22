import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'anthropometry_list_screen.dart';

class AnthropometryEditScreen extends ConsumerStatefulWidget {
  final AnthropometryMeasurement? measurement;
  final String clientId;

  const AnthropometryEditScreen({
    super.key,
    this.measurement,
    required this.clientId,
  });

  @override
  ConsumerState<AnthropometryEditScreen> createState() =>
      _AnthropometryEditScreenState();
}

class _AnthropometryEditScreenState
    extends ConsumerState<AnthropometryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dateTime;
  late final Map<String, TextEditingController> _controllers;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final m = widget.measurement;
    _dateTime = m?.dateTime ?? DateTime.now();
    _controllers = {
      'weight': TextEditingController(text: m?.weight.toString()),
      'shouldersCirc':
          TextEditingController(text: m?.shouldersCirc.toString()),
      'breastCirc': TextEditingController(text: m?.breastCirc.toString()),
      'waistCirc': TextEditingController(text: m?.waistCirc.toString()),
      'hipsCirc': TextEditingController(text: m?.hipsCirc.toString()),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Safe to parse because validators have already checked.
        final weight = double.parse(_controllers['weight']!.text);
        final shouldersCirc = int.parse(_controllers['shouldersCirc']!.text);
        final breastCirc = int.parse(_controllers['breastCirc']!.text);
        final waistCirc = int.parse(_controllers['waistCirc']!.text);
        final hipsCirc = int.parse(_controllers['hipsCirc']!.text);

        final measurementToSave = (widget.measurement ??
                AnthropometryMeasurement(
                  userId: widget.clientId,
                  dateTime: _dateTime,
                  // Provide all required fields for creation
                  weight: weight,
                  shouldersCirc: shouldersCirc,
                  breastCirc: breastCirc,
                  waistCirc: waistCirc,
                  hipsCirc: hipsCirc,
                ))
            .copyWith(
          dateTime: _dateTime,
          weight: weight,
          shouldersCirc: shouldersCirc,
          breastCirc: breastCirc,
          waistCirc: waistCirc,
          hipsCirc: hipsCirc,
        );

        // Use the appropriate API service method
        await ApiService.saveAnthropometryMeasurementForClient(
            widget.clientId, measurementToSave);

        ref.invalidate(anthropometryListProvider(
          AnthropometryListParams(
            clientId: widget.clientId,
            includeArchived: ref.read(showArchivedProvider),
          ),
        ));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка сохранения: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildTextFormField(String label, String key, {bool isDouble = false}) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Поле не может быть пустым';
        }
        if (isDouble) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Введите корректное число';
          }
          if (number == 0) {
            return 'Значение не может быть 0';
          }
        } else {
          final number = int.tryParse(value);
          if (number == null) {
            return 'Введите корректное целое число';
          }
          if (number == 0) {
            return 'Значение не может быть 0';
          }
        }
        return null;
      },
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _dateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.measurement == null ? 'Новый замер' : 'Редактировать замер'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
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
              ListTile(
                title: Text(
                    'Дата замера: ${DateFormat.yMMMd('ru').add_jm().format(_dateTime)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: widget.measurement == null
                    ? () => _selectDateTime(context)
                    : null,
              ),
              _buildTextFormField('Вес (кг)', 'weight', isDouble: true),
              _buildTextFormField('Обхват плеч (см)', 'shouldersCirc'),
              _buildTextFormField('Обхват груди (см)', 'breastCirc'),
              _buildTextFormField('Обхват талии (см)', 'waistCirc'),
              _buildTextFormField('Обхват бедер (см)', 'hipsCirc'),
            ],
          ),
        ),
      ),
    );
  }
}
