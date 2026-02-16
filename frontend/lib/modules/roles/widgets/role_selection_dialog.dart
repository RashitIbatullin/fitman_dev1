import 'package:flutter/material.dart';
import '../models/role.dart';

class RoleSelectionDialog extends StatelessWidget {
  final List<Role> roles;

  const RoleSelectionDialog({super.key, required this.roles});

  // Helper function to map role name to a constant IconData
  IconData _getIconForRole(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'instructor':
        return Icons.fitness_center;
      case 'client':
        return Icons.person;
      // Add other roles here
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите роль'),
      content: SingleChildScrollView(
        child: ListBody(
          children: roles.map((role) {
            return ListTile(
              title: Text(role.title),
              leading: Icon(_getIconForRole(role.name)), // Using the helper function
              onTap: () {
                Navigator.of(context).pop(role);
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Отмена'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
