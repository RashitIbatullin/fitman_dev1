import 'package:fitman_app/widgets/logout_button.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';

import '../modules/users/providers/auth_provider.dart';
import 'manager/schedule_page.dart';
import 'manager/user_list_page.dart';
import 'manager/timesheet_page.dart';
import 'package:fitman_app/modules/groups/screens/training/training_groups_screen.dart';

import 'package:fitman_app/modules/employees/screens/competency_screen.dart';

class ManagerDashboard extends ConsumerWidget {
  final User? manager;
  final bool showBackButton;
  const ManagerDashboard({super.key, this.manager, required this.showBackButton});

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
    final user = manager ?? ref.watch(authProvider).value!.user!;

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
          navigateTo(const UserListPage());
          break;
        case 2:
          navigateTo(const SchedulePage());
          break;
        case 3:
          navigateTo(const TimesheetPage());
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: showBackButton ? const BackButton() : null,
        title: const Text('Главное'),
         actions: [
          if (manager == null) const LogoutButton(),
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
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Пользователи'),
              onTap: () => handleDrawerTap(const UserListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Расписание'),
              onTap: () => handleDrawerTap(const SchedulePage()),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Табели'),
              onTap: () => handleDrawerTap(const TimesheetPage()),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Группы тренинга'),
              onTap: () => handleDrawerTap(TrainingGroupsScreen(userId: user.id, userRole: 'manager')),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Компетенции ТО'),
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
      body: const Center(child: Text('Главный экран менеджера')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Пользователи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Табели',
          ),
        ],
        currentIndex: 0, // Always on 'Главное'
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
