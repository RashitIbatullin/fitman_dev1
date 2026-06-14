import 'package:fitman_app/widgets/logout_button.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:fitman_app/modules/employees/screens/competency_screen.dart';

import '../modules/users/providers/auth_provider.dart';
import 'manager/schedule_page.dart';
import 'manager/user_list_page.dart';
import 'package:fitman_app/modules/groups/screens/training/training_groups_screen.dart';

class TrainerDashboard extends ConsumerWidget {
  final User? trainer;
  final bool showBackButton;
  const TrainerDashboard({super.key, this.trainer, required this.showBackButton});

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
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

    if (confirmed == true && context.mounted) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = trainer ?? ref.watch(authProvider).value!.user!;

    void navigateTo(Widget page) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
    
    void handleDrawerTap(Widget? page) {
      Navigator.pop(context); // Close drawer first
      if (page != null) {
        navigateTo(page);
      }
    }

    void onBottomNavTapped(int index) {
      switch (index) {
        case 0:
          // Already on the main screen, do nothing.
          break;
        case 1:
          navigateTo(ProfileScreen(user: user));
          break;
        case 2:
          navigateTo(const UserListPage());
          break;
        case 3:
          navigateTo(const SchedulePage());
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: showBackButton ? const BackButton() : null,
        title: const Text('Главное'),
        actions: [
          if (trainer == null) const LogoutButton(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.fullName),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? Text(user.shortName.isNotEmpty ? user.shortName[0] : '')
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Профиль'),
              onTap: () => handleDrawerTap(ProfileScreen(user: user)),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Клиенты'),
              onTap: () => handleDrawerTap(const UserListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Расписание'),
              onTap: () => handleDrawerTap(const SchedulePage()),
            ),
             ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Группы тренинга'),
              onTap: () => handleDrawerTap(TrainingGroupsScreen(userId: user.id, userRole: 'trainer')),
            ),
             ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Компетенции'),
              onTap: () => handleDrawerTap(
                CompetencyScreen(
                  employeeId: user.id.toString(),
                  employeeName: user.shortName,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context, ref);
              },
            )
          ],
        ),
      ),
      body: const Center(child: Text('Главный экран тренера')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Клиенты'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Расписание',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
