import 'package:fitman_app/screens/admin_dashboard.dart';
import 'package:fitman_app/screens/client_dashboard.dart';
import 'package:fitman_app/screens/instructor_dashboard.dart';
import 'package:fitman_app/screens/manager_dashboard.dart';
import 'package:fitman_app/screens/trainer_dashboard.dart';
import 'package:fitman_app/modules/roles/screens/unknown_role_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../modules/roles/models/role.dart';
import '../modules/roles/widgets/role_dialog_manager.dart';

/// This is an invisible widget whose only purpose is to listen to the
/// auth state and perform navigations.
class AuthNavigator extends ConsumerWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const AuthNavigator({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      _onAuthStateChange(context, ref, previous, next);
    });
    return child;
  }

  void _onAuthStateChange(
    BuildContext context, // Keep context for dialogs
    WidgetRef ref,
    AsyncValue<AuthState>? previous,
    AsyncValue<AuthState> next,
  ) {
    next.when(
      data: (authState) {
        final user = authState.user;
        final selectedRole = authState.selectedRole;
        
        // Safely get the previous data state, if it exists.
        final previousData = previous?.whenOrNull(data: (d) => d);

        // --- Handle Logout ---
        if (user == null) {
          // If user was previously logged in, pop all routes to return to LoginScreen.
          if (previousData?.user != null) {
            navigatorKey.currentState!.popUntil((route) => route.isFirst);
          }
          return;
        }

        // --- Handle Login & Navigation ---
        // We only want to trigger navigation/dialogs on specific state transitions.
        final wasRoleNull = previousData?.selectedRole == null;

        // Case 1: Multi-role user needs to select a role.
        if (user.roles.length > 1 && selectedRole == null && wasRoleNull) {
          _showRoleSelectionDialog(context, ref, user.roles);
          return;
        }

        // Case 2: Role is now selected, time to navigate.
        if (selectedRole != null && wasRoleNull) {
          _navigateToDashboard(selectedRole);
        }
      },
      loading: () {}, // Do nothing when loading
      error: (err, stack) {
        // Optionally, show a SnackBar or handle error
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(content: Text('Ошибка аутентификации: $err')),
          );
        }
      },
    );
  }

  Future<void> _showRoleSelectionDialog(BuildContext context, WidgetRef ref, List<Role> roles) async {
    final Role? chosenRole = await RoleDialogManager.show(context, roles);
    if (chosenRole != null) {
      ref.read(authProvider.notifier).setSelectedRole(chosenRole);
    } else {
      ref.read(authProvider.notifier).logout();
    }
  }

  void _navigateToDashboard(Role role) {
    final dashboard = _getDashboard(role, showBackButton: false);
    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (ctx) => dashboard),
    );
  }

  Widget _getDashboard(Role role, {required bool showBackButton}) {
    switch (role.name) {
      case 'admin':
        return AdminDashboard(showBackButton: showBackButton);
      case 'manager':
        return ManagerDashboard(showBackButton: showBackButton);
      case 'trainer':
        return TrainerDashboard(showBackButton: showBackButton);
      case 'instructor':
        return InstructorDashboard(showBackButton: showBackButton);
      case 'client':
        return ClientDashboard(showBackButton: showBackButton);
      default:
        return const UnknownRoleScreen();
    }
  }
}
