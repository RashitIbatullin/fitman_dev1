import '../modules/groups/screens/analytic/analytic_groups_screen.dart';
import '../modules/groups/screens/training/training_groups_screen.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../modules/users/screens/users_list_screen.dart';
import 'admin/catalogs_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final bool showBackButton;
  const AdminDashboard({super.key, required this.showBackButton});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;
  late ScrollController _scrollController;
  bool _showBars = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_selectedIndex != 1) return; // Only for Users tab

    // Show bars if we are at the top of the page
    if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent) {
      if (!_showBars) {
        setState(() => _showBars = true);
      }
      return;
    }

    final userScrollDirection = _scrollController.position.userScrollDirection;

    if (userScrollDirection == ScrollDirection.reverse) {
      if (_showBars) setState(() => _showBars = false);
    } else if (userScrollDirection == ScrollDirection.forward) {
      if (!_showBars) setState(() => _showBars = true);
    }
  }

  final List<String> _titles = const [
    'Главное',
    'Пользователи',
    'Группы тренинга', // This title is now associated with a push, not IndexedStack
  ];

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value?.user;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? ''),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(user?.shortName.isNotEmpty == true ? user!.shortName[0] : '')
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Профиль'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (user != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
              }
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
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выйти'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              showDialog(
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
              ).then((value) {
                if (value == true) {
                  ref.read(authProvider.notifier).logout();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Only include screens for IndexedStack. TrainingGroupsScreen will be pushed.
    final List<Widget> views = [
      const Center(child: Text('Главное')),
      UsersListScreen(scrollController: _scrollController, showToolbar: _showBars),
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
      if (index != _selectedIndex && !_showBars) {
        setState(() {
          _showBars = true;
        });
      }
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showBars ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showBars ? kToolbarHeight : 0,
          child: AppBar(
            title: Text(_titles[_selectedIndex]),
          ),
        ),
      ),
      drawer: _buildDrawer(context, ref),
      body: IndexedStack(index: _selectedIndex, children: views),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _showBars ? kBottomNavigationBarHeight : 0,
        child: Wrap(
          children: [
            BottomNavigationBar(
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
          ],
        ),
      ),
    );
  }
}