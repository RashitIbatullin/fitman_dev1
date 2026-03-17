import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/api_service.dart';
import '../../../screens/client/full_screen_photo_editor.dart';
import 'employees_list_screen.dart';
import 'manage_user_roles_screen.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final User user;

  const EditEmployeeScreen({super.key, required this.user});

  @override
  ConsumerState<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _specializationController = TextEditingController();
  final _workExperienceController = TextEditingController();

  String? _selectedGender;
  bool _sendNotification = true;
  bool _trackCalories = true;
  int _hourNotification = 1;
  double _coeffActivity = 1.2;
  String? _photoUrl;

  bool _canMaintainEquipment = false;
  bool _isDuty = false;
  bool _canReplaceTrainer = false;
  bool _canCreatePlan = false;

  Matrix4 _currentAvatarTransform = Matrix4.identity();
  String? _avatarUrlWithCacheBust;
  ui.Image? _editedAvatarImage;
  bool _hasUnsavedChanges = false;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _emailController.text = user.email;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _middleNameController.text = user.middleName ?? '';
    _phoneController.text = user.phone ?? '';
    _dateOfBirthController.text =
        user.dateOfBirth?.toIso8601String().split('T').first ?? '';
    _selectedGender = user.gender;
    _sendNotification = user.sendNotification;
    _photoUrl = user.photoUrl;

    // Client specific
    _trackCalories = user.clientProfile?.trackCalories ?? true;
    _coeffActivity = user.clientProfile?.coeffActivity ?? 1.2;

    // Employee specific
    _specializationController.text = user.employeeProfile?.specialization ?? '';
    _workExperienceController.text = user.employeeProfile?.workExperience?.toString() ?? '';
    _canMaintainEquipment = user.employeeProfile?.canMaintainEquipment ?? false;
    _isDuty = (user.instructorProfile?.isDuty ?? user.managerProfile?.isDuty) ?? false;
    _canReplaceTrainer = user.instructorProfile?.canReplaceTrainer ?? false;
    _canCreatePlan = user.instructorProfile?.canCreatePlan ?? false;


    _updateAvatarUrlForCacheBusting();
  }

  void _updateAvatarUrlForCacheBusting() {
    if (_photoUrl != null) {
      setState(() {
        _avatarUrlWithCacheBust =
            '${Uri.parse(ApiService.baseUrl).replace(path: _photoUrl!).toString()}?v=${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  Future<void> _uploadAndReplaceAvatar() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final platformFile = result.files.single;
    final fileName = platformFile.name;
    final fileBytes = platformFile.bytes ??
        (platformFile.path != null
            ? await File(platformFile.path!).readAsBytes()
            : null);

    if (fileBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Не удалось получить данные файла изображения.')),
        );
      }
      return;
    }

    try {
      final response =
          await ApiService.uploadAvatar(fileBytes, fileName, widget.user.id);
      if (!mounted) return;

      setState(() {
        _photoUrl = response['photoUrl'];
        _editedAvatarImage = null;
        _hasUnsavedChanges = false;
        _currentAvatarTransform = Matrix4.identity();
        _updateAvatarUrlForCacheBusting();
      });
      ref.invalidate(employeesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото успешно сохранено'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки нового фото аватара: $e')),
      );
    }
  }

  Future<void> _saveAvatar() async {
    if (_editedAvatarImage == null) return;

    final byteData =
        await _editedAvatarImage!.toByteData(format: ui.ImageByteFormat.png);
    if (!mounted) return;
    final imageBytes = byteData?.buffer.asUint8List();

    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось обработать изображение')),
      );
      return;
    }

    try {
      final response = await ApiService.uploadAvatar(
          imageBytes, 'avatar.png', widget.user.id);
      if (!mounted) return;

      setState(() {
        _photoUrl = response['photoUrl'];
        _editedAvatarImage = null;
        _hasUnsavedChanges = false;
        _updateAvatarUrlForCacheBusting();
      });

      ref.invalidate(employeesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото успешно сохранено'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения фото аватара: $e')),
      );
    }
  }

  Future<void> _editAvatar() async {
    if (_avatarUrlWithCacheBust == null) {
      _uploadAndReplaceAvatar();
      return;
    }

    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoEditor(
          imageUrl: _avatarUrlWithCacheBust!,
          initialTransform: _currentAvatarTransform,
        ),
      ),
    );

    if (result != null && result is (ui.Image, Matrix4)) {
      setState(() {
        _editedAvatarImage = result.$1;
        _currentAvatarTransform = result.$2;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic>? clientProfileData;
      if (widget.user.roles.any((r) => r.name == 'client')) {
        clientProfileData = {
          'track_calories': _trackCalories,
          'coeff_activity': _coeffActivity,
        };
      }

      Map<String, dynamic>? employeeProfileData;
      Map<String, dynamic>? instructorProfileData;
      Map<String, dynamic>? managerProfileData;
      Map<String, dynamic>? trainerProfileData;

      bool isEmployee = widget.user.roles.any((r) => ['manager', 'trainer', 'instructor'].contains(r.name));

      if (isEmployee) {
        employeeProfileData = {
          'specialization': _specializationController.text.trim(),
          'work_experience': int.tryParse(_workExperienceController.text.trim()),
          'can_maintain_equipment': _canMaintainEquipment,
        };

        if (widget.user.roles.any((r) => r.name == 'instructor')) {
          instructorProfileData = {
            'is_duty': _isDuty,
            'can_replace_trainer': _canReplaceTrainer,
            'can_create_plan': _canCreatePlan,
          };
        }
        if (widget.user.roles.any((r) => r.name == 'manager')) {
          managerProfileData = {
            'is_duty': _isDuty,
          };
        }
        if (widget.user.roles.any((r) => r.name == 'trainer')) {
          trainerProfileData = {}; // Empty map as it has no specific fields
        }
      }

      final request = UpdateUserRequest(
        id: widget.user.id,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dateOfBirthController.text.trim().isNotEmpty
            ? DateTime.parse(_dateOfBirthController.text.trim())
            : null,
        clientProfile: clientProfileData,
        employeeProfile: employeeProfileData,
        instructorProfile: instructorProfileData,
        managerProfile: managerProfileData,
        trainerProfile: trainerProfileData,
      );

      final updatedUser = await ApiService.updateUser(request);
      
      ref.invalidate(employeesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пользователь успешно обновлен'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, updatedUser);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
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
    final authState = ref.watch(authProvider);
    final currentUser = authState.value?.user;
    final canEditPhoto =
        currentUser != null && !currentUser.roles.any((role) => role.name == 'client');

    final isEmployee = widget.user.roles.any((r) => ['manager', 'trainer', 'instructor'].contains(r.name));

    return Scaffold(
      appBar: AppBar(title: Text('Редактирование: ${widget.user.shortName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (canEditPhoto) ...[
                _buildAvatarSection(),
                const SizedBox(height: 16),
              ],
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              if (widget.user.roles.any((r) => r.name == 'client'))
                _buildClientSpecificSection(),
              if (isEmployee)
                _buildEmployeeInfoSection(),
              if (!widget.user.roles.any((r) => r.name == 'admin')) ...[
                _buildNotificationSection(),
                const SizedBox(height: 20),
                _buildRolesSection(),
                const SizedBox(height: 20),
              ],
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    Widget avatarContent;
    if (_hasUnsavedChanges && _editedAvatarImage != null) {
      avatarContent = RawImage(image: _editedAvatarImage!, fit: BoxFit.cover);
    }
    else if (_photoUrl != null) {
      avatarContent = Image.network(_avatarUrlWithCacheBust!, fit: BoxFit.cover);
    }
    else {
      avatarContent = const Icon(Icons.person, size: 50);
    }

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _hasUnsavedChanges
                ? null
                : (_photoUrl != null ? _editAvatar : _uploadAndReplaceAvatar),
            child: ClipOval(
              child: SizedBox(
                width: 100,
                height: 100,
                child: avatarContent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.cloud_upload),
                tooltip: 'Загрузить новое фото',
                onPressed: _uploadAndReplaceAvatar,
              ),
              if (_photoUrl != null)
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Сохранить изменения',
                  onPressed: _hasUnsavedChanges ? _saveAvatar : null,
                ),
            ],
          )
        ],
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
                labelText: 'Телефон',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final phoneRegExp = RegExp(
                      r'^(\+7|8)?[\s-]?\(?[489][0-9]{2}\)?[\s-]?[0-9]{3}[\s-]?[0-9]{2}[\s-]?[0-9]{2}$');
                  if (!phoneRegExp.hasMatch(value)) {
                    return 'Неверный формат телефона';
                  }
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
                final emailRegExp =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegExp.hasMatch(value)) {
                  return 'Неверный формат email';
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
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Введите фамилию' : null,
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
                labelText: 'Пол',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'мужской', child: Text('Мужской')),
                DropdownMenuItem(value: 'женский', child: Text('Женский')),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Дата рождения',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _dateOfBirthController.text.isNotEmpty
                      ? DateTime.parse(_dateOfBirthController.text)
                      : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  _dateOfBirthController.text =
                      selectedDate.toIso8601String().split('T').first;
                }
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

  Widget _buildEmployeeInfoSection() {
    final user = widget.user;
    final isInstructor = user.roles.any((r) => r.name == 'instructor');
    final isManager = user.roles.any((r) => r.name == 'manager');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Данные сотрудника',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specializationController,
              decoration: const InputDecoration(
                labelText: 'Специализация',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workExperienceController,
              decoration: const InputDecoration(
                labelText: 'Опыт работы (лет)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Может обслуживать оборудование'),
              value: _canMaintainEquipment,
              onChanged: (value) {
                setState(() {
                  _canMaintainEquipment = value;
                });
              },
            ),
            if (isInstructor || isManager)
              SwitchListTile(
                title: const Text('Дежурный'),
                value: _isDuty,
                onChanged: (value) {
                  setState(() {
                    _isDuty = value;
                  });
                },
              ),
            if (isInstructor) ...[
              SwitchListTile(
                title: const Text('Может заменять тренера'),
                value: _canReplaceTrainer,
                onChanged: (value) {
                  setState(() {
                    _canReplaceTrainer = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Может составлять планы'),
                value: _canCreatePlan,
                onChanged: (value) {
                  setState(() {
                    _canCreatePlan = value;
                  });
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
            onPressed: _isLoading ? null : _updateUser,
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
                    'Сохранить изменения',
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

  Widget _buildRolesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Управление ролями',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageUserRolesScreen(user: widget.user),
                    ),
                  );
                  ref.invalidate(employeesProvider);
                },
                icon: const Icon(Icons.manage_accounts),
                label: const Text('Изменить роли пользователя'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _specializationController.dispose();
    _workExperienceController.dispose();
    super.dispose();
  }
}
