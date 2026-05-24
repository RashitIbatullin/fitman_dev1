import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modules/users/providers/auth_provider.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Выйти',
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Подтверждение выхода'),
              content: const Text('Вы уверены, что хотите выйти?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Нет'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Да'),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          // The logout method returns a future, but we don't need to await it
          // here because the AuthNavigator will handle all UI changes,
          // including the loading state.
          ref.read(authProvider.notifier).logout();
        }
      },
    );
  }
}
