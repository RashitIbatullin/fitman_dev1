import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../users/models/user.dart';
import '../../../providers/auth_provider.dart';
import 'role_selection_dialog.dart';
import '../models/role.dart';

class RoleDialogManager extends ConsumerStatefulWidget {
  final User user;
  const RoleDialogManager({super.key, required this.user});

  @override
  ConsumerState<RoleDialogManager> createState() => _RoleDialogManagerState();

  static Future<Role?> show(BuildContext context, List<Role> roles) {
    return showDialog<Role?>(
      context: context,
      builder: (context) => RoleSelectionDialog(roles: roles),
    );
  }
}

class _RoleDialogManagerState extends ConsumerState<RoleDialogManager> {
  @override
  void initState() {
    super.initState();
    // Показываем диалог сразу после построения первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) => _showRoleDialog());
  }

  void _showRoleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Пользователь обязан сделать выбор
      builder: (context) => RoleSelectionDialog(roles: widget.user.roles),
    ).then((selectedRole) {
      if (selectedRole != null) {
        ref.read(authProvider.notifier).setSelectedRole(selectedRole);
      } else {
        // Если диалог был закрыт без выбора (например, системной кнопкой назад),
        // разлогиниваем пользователя, чтобы не оставаться в неопределенном состоянии.
        ref.read(authProvider.notifier).logout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Этот виджет просто отображает пустой экран с индикатором загрузки,
    // пока диалог выбора роли активен.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
