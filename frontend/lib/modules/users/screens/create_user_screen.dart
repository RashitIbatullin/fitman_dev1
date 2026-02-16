import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../../services/api_service.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  final String userRole; // This can be a suggestion

  const CreateUserScreen({super.key, required this.userRole});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  final List<String> _selectedRoleNames = [];
  String? _selectedGender;
  bool _sendNotification = true;
  bool _trackCalories = true;
  int _hourNotification = 1;
  double _coeffActivity = 1.2;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedRoleNames.add(widget.userRole);
  }

  void _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    final password = String.fromCharCodes(
      List.generate(12, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    _passwordController.text = password;
  }

  String _getRoleDisplayName(String roleName) {
    switch (roleName) {
      case 'admin':
        return 'Администратор';
      case 'manager':
        return 'Менеджер';
      case 'trainer':
        return 'Тренер';
      case 'instructor':
        return 'Инструктор';
      case 'client':
        return 'Клиент';
      default:
        return 'Пользователь';
    }
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    // --- Клиентская валидация ролей ---
    if (_selectedRoleNames.isEmpty) {
      setState(() {
        _error = 'Необходимо выбрать хотя бы одну роль.';
      });
      return;
    }
    // Правила валидации уже применяются при выборе чекбоксов, но дублируем на всякий случай
    if (_selectedRoleNames.contains('client') &&
        _selectedRoleNames.length > 1) {
      setState(() {
        _error = 'Пользователь с ролью "Клиент" не может иметь другие роли.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Conditionally create the client profile map
      Map<String, dynamic>? clientProfileData;
      if (_selectedRoleNames.contains('client')) {
        clientProfileData = {
          'track_calories': _trackCalories,
          'coeff_activity': _coeffActivity,
        };
      }

      final request = CreateUserRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim().isNotEmpty
            ? _middleNameController.text.trim()
            : null,
        roles: _selectedRoleNames,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        gender: _selectedGender,
        dateOfBirth: _dateOfBirthController.text.trim().isNotEmpty
            ? DateTime.parse(_dateOfBirthController.text.trim())
            : null,
        sendNotification: _sendNotification,
        hourNotification: _hourNotification,
        clientProfile: clientProfileData,
      );

      final newUser = await ApiService.createUser(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пользователь ${request.email} успешно создан'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, newUser); // Возвращаем созданного пользователя
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создание: ${_getRoleDisplayName(widget.userRole)}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              if (_selectedRoleNames.contains('client'))
                _buildClientSpecificSection(),
              if (widget.userRole != 'admin')
                _buildNotificationSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Основная информация',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите телефон';
                }
                final phoneRegExp = RegExp(r'^(\+7|8)?[\s-]?\(?[489][0-9]{2}\)?[\s-]?[0-9]{3}[\s-]?[0-9]{2}[\s-]?[0-9]{2}$');
                if (!phoneRegExp.hasMatch(value)) {
                  return 'Неверный формат телефона';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Введите email';
                final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegExp.hasMatch(value)) {
                  return 'Неверный формат email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generatePassword,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Введите пароль';
                if (value.length < 6) {
                  return 'Пароль должен быть не менее 6 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Введите фамилию'
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Введите имя' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _middleNameController,
              decoration: const InputDecoration(
                labelText: 'Отчество',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Пол *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'мужской', child: Text('Мужской')),
                DropdownMenuItem(value: 'женский', child: Text('Женский')),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, выберите пол';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Дата рождения *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  _dateOfBirthController.text = selectedDate.toIso8601String().split('T').first;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, выберите дату рождения';
                }
                return null;
              },
            ),

          ],
        ),
      ),
    );
  }



  Widget _buildClientSpecificSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Данные клиента',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Учет калорий'),
              value: _trackCalories,
              onChanged: (value) {
                setState(() {
                  _trackCalories = value;
                });
              },
            ),
            if (_trackCalories) ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _coeffActivity.toString(),
                decoration: const InputDecoration(
                  labelText: 'Коэффициент активности',
                  border: OutlineInputBorder(),
                  helperText: 'Минимальный коэффициент активности: 1.2',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final coeff = double.tryParse(value);
                  if (coeff != null && coeff >= 1.2) {
                    setState(() {
                      _coeffActivity = coeff;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Настройки уведомлений',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Посылать уведомления'),
              value: _sendNotification,
              onChanged: (value) {
                setState(() {
                  _sendNotification = value;
                });
              },
            ),
            if (_sendNotification) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _hourNotification,
                decoration: const InputDecoration(
                  labelText: 'Уведомление до начала занятий (часов)',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3, 4, 5, 6, 12, 24]
                    .map(
                      (hour) => DropdownMenuItem(
                        value: hour,
                        child: Text('$hour час(а/ов)'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _hourNotification = value!;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createUser,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Создать пользователя',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
}