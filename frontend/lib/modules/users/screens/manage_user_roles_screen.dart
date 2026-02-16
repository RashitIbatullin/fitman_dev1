import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../../roles/models/role.dart';
import '../../../services/api_service.dart';

class ManageUserRolesScreen extends ConsumerStatefulWidget {
  final User user;

  const ManageUserRolesScreen({super.key, required this.user});

  @override
  ConsumerState<ManageUserRolesScreen> createState() =>
      _ManageUserRolesScreenState();
}

class _ManageUserRolesScreenState extends ConsumerState<ManageUserRolesScreen> {
  List<Role> _allRoles = [];
  List<String> _selectedRoleNames = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedRoleNames = widget.user.roles.map((r) => r.name).toList();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await ApiService.getAllRoles();
      setState(() {
        // Фильтруем роль "Клиент" согласно требованию
        _allRoles = roles.where((role) => role.name != 'client').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRoles() async {
    // --- Клиентская валидация ---
    if (_selectedRoleNames.isEmpty) {
      setState(() => _error = 'У пользователя должна быть хотя бы одна роль.');
      return;
    }
    if (_selectedRoleNames.contains('client') &&
        _selectedRoleNames.length > 1) {
      setState(
        () => _error =
            'Пользователь с ролью "Клиент" не может иметь другие роли.',
      );
      return;
    }
    // --- Конец валидации ---

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiService.updateUserRoles(widget.user.id, _selectedRoleNames);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Роли успешно обновлены'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Возвращаем true для обновления списка
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Управление ролями: ${widget.user.shortName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _allRoles.isEmpty
          ? Center(child: Text('Ошибка загрузки ролей: $_error'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allRoles.length,
                      itemBuilder: (context, index) {
                        final role = _allRoles[index];
                        final isSelected = _selectedRoleNames.contains(
                          role.name,
                        );

                        // --- Логика блокировки чекбоксов ---
                        final isClientRole = role.name == 'client';
                        final isClientSelectedInList = _selectedRoleNames
                            .contains('client');
                        final isEmployeeSelected = _selectedRoleNames.any(
                          (name) => name != 'client',
                        );
                        final isTheOnlyRole =
                            _selectedRoleNames.length == 1 && isSelected;

                        final bool isDisabled =
                            // Нельзя совмещать клиента с другими ролями
                            (isClientSelectedInList && !isClientRole) ||
                            (isEmployeeSelected && isClientRole) ||
                            // Нельзя убрать последнюю роль
                            isTheOnlyRole;

                        return CheckboxListTile(
                          title: Text(role.title),
                          value: isSelected,
                          onChanged: isDisabled
                              ? null
                              : (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedRoleNames.add(role.name);
                                    } else {
                                      _selectedRoleNames.remove(role.name);
                                    }
                                  });
                                },
                        );
                      },
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateRoles,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child: const Text('Сохранить изменения'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
