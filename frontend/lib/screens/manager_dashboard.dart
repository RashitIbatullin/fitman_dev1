import 'package:fitman_app/modules/users/models/user.dart';
import 'package:fitman_app/modules/users/screens/users_list_screen.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';

import 'manager/schedule_view.dart';

class ManagerDashboard extends ConsumerStatefulWidget {
  final User? manager;
  final bool showBackButton;
  const ManagerDashboard({super.key, this.manager, required this.showBackButton});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard> {
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
    if (_selectedIndex != 1) {
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
    'Расписание',
    'Табели',
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex && !_showBars) {
      setState(() {
        _showBars = true;
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.manager ?? ref.watch(authProvider).value?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> views = [
      const Center(child: Text('Главное')),
      UsersListScreen(scrollController: _scrollController, showToolbar: _showBars),
      const ScheduleView(),
      const Center(child: Text('Табели - в разработке')),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showBars ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showBars ? kToolbarHeight : 0,
          child: AppBar(
            leading: widget.showBackButton ? const BackButton() : null,
            title: Text(_titles[_selectedIndex]),
             actions: [
              if (widget.manager == null)
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Выйти',
                  onPressed: () {
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
        ),
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
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: user)));
              },
            ),
          ],
        ),
      ),
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
                  icon: Icon(Icons.calendar_today),
                  label: 'Расписание',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  label: 'Табели',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
          ],
        ),
      ),
    );
  }
}
