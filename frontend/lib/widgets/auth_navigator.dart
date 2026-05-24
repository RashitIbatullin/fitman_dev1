import 'package:fitman_app/modules/roles/widgets/role_dialog_manager.dart';
import 'package:fitman_app/screens/admin_dashboard.dart';
import 'package:fitman_app/modules/clients/screens/client_dashboard.dart';
import 'package:fitman_app/screens/instructor_dashboard.dart';
import 'package:fitman_app/screens/login_screen.dart';
import 'package:fitman_app/screens/manager_dashboard.dart';
import 'package:fitman_app/screens/trainer_dashboard.dart';
import 'package:fitman_app/modules/roles/screens/unknown_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_common/fitman_common.dart';
import '../modules/users/providers/auth_provider.dart';

class AuthNavigator extends ConsumerWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      data: (state) {
        final user = state.user;
        final selectedRole = state.selectedRole;

        if (user == null) {
          return const LoginScreen();
        }

        // User is logged in, but role is not selected
        if (selectedRole == null) {
          // If user has multiple roles, show selection dialog.
          // The RoleDialogManager is a widget that handles its own dialog presentation.
          if (user.roles.length > 1) {
            return RoleDialogManager(user: user);
          }
          // If user has one role, it should have been selected on login.
          // If they have no roles, or something went wrong, show unknown role screen.
          return const UnknownRoleScreen();
        }

        // User and role are selected, navigate to the correct dashboard.
        return _getDashboard(selectedRole);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Произошла ошибка: $err'),
          ),
        ),
      ),
    );
  }

  Widget _getDashboard(Role role) {
    switch (role.name) {
      case 'admin':
        return const AdminDashboard(showBackButton: false);
      case 'manager':
        return const ManagerDashboard(showBackButton: false);
      case 'trainer':
        return const TrainerDashboard(showBackButton: false);
      case 'instructor':
        return const InstructorDashboard(showBackButton: false);
      case 'client':
        return const ClientDashboard(showBackButton: false);
      default:
        return const UnknownRoleScreen();
    }
  }
}
