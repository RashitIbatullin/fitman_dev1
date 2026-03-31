import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/modules/users/screens/user_list_screen.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';

import 'manager/schedule_view.dart';

import 'package:fitman_app/modules/employees/screens/competency_screen.dart';

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
      UserListScreen(scrollController: _scrollController, showToolbar: _showBars),
      const ScheduleView(),
      const Center(child: Text('Табели - в разработке')),
    ];

    void handleMenuSelection(String value) {
      switch (value) {
        case 'main':
          _onItemTapped(0);
          break;
        case 'users':
          _onItemTapped(1);
          break;
        case 'schedule':
          _onItemTapped(2);
          break;
        case 'timesheet':
          _onItemTapped(3);
          break;
        case 'competencies':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompetencyScreen(
                employeeId: user.id.toString(),
                employeeName: user.shortName,
              ),
            ),
          );
          break;
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showBars ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showBars ? kToolbarHeight : 0,
          child: AppBar(
            leadingWidth: widget.showBackButton ? 96 : 56,
            leading: Row(
              children: [
                if (widget.showBackButton) const BackButton(),
                if (widget.showBackButton)
                  PopupMenuButton<String>(
                    onSelected: handleMenuSelection,
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'main',
                        child: Text('Главное'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'users',
                        child: Text('Пользователи'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'schedule',
                        child: Text('Расписание'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'timesheet',
                        child: Text('Табели'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'competencies',
                        child: Text('Компетенции ТО'),
                      ),
                    ],
                  ),
              ],
            ),
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
