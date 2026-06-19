import '../widgets/logout_button.dart';
import '../modules/groups/screens/analytic/analytic_groups_screen.dart';
import '../modules/groups/screens/training/training_groups_screen.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modules/users/providers/auth_provider.dart';
import '../modules/users/screens/user_list_screen.dart';
import 'admin/catalogs_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final bool showBackButton;
  const AdminDashboard({super.key, required this.showBackButton});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    'Главное',
    'Пользователи',
    'Группы тренинга', // This title is now associated with a push, not IndexedStack
  ];

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
    if (confirmed == true) {
      if (!context.mounted) return;
      ref.read(authProvider.notifier).logout();
    }
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value!.user!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.fullName),
            accountEmail: Text(user.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(user.shortName.isNotEmpty == true ? user.shortName[0] : '')
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Профиль'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Каталоги'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Группы тренинга'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainingGroupsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Группы анализа'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticGroupsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Аналитика'),
            onTap: () {
              Navigator.pop(context); // Close drawer
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Аналитика - в разработке')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Настройки'),
            onTap: () {
               Navigator.pop(context); // Close drawer
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Настройки - в разработке')),
              );
            },
          ),
          const Divider(),
          Builder(
            builder: (drawerContext) => ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: () {
                // First close the drawer
                Navigator.pop(drawerContext);
                // Then show the logout dialog
                _showLogoutDialog(context, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only include screens for IndexedStack. TrainingGroupsScreen will be pushed.
    final List<Widget> views = [
      const Center(child: Text('Главное')),
      const UserListScreen(showToolbar: true),
      // TrainingGroupsScreen is removed from IndexedStack views
    ];

    void onItemTapped(int index) {
      if (index == 2) { // 'Группы тренинга' bottom nav item
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TrainingGroupsScreen()),
        );
        // Do not update _selectedIndex, stay on current tab (e.g., 'Главное')
        return;
      }
      setState(() {
        _selectedIndex = index;
      });
    }

    return PopScope(
      canPop: widget.showBackButton,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _showLogoutDialog(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_selectedIndex]),
          actions: const [
            LogoutButton(),
          ],
        ),
        drawer: _buildDrawer(context, ref),
        body: IndexedStack(index: _selectedIndex, children: views),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Пользователи',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Группы тренинга', // Label updated
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}