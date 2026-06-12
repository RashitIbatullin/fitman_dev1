import 'package:fitman_app/widgets/logout_button.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/modules/users/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';

import '../modules/users/providers/auth_provider.dart';
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

  Future<void> _showLogoutDialog() async {
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
    final user = widget.manager ?? ref.watch(authProvider).value!.user!;

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
            leading: widget.showBackButton
                ? Row(
                    children: [
                      const BackButton(),
                      PopupMenuButton<String>(
                        onSelected: handleMenuSelection,
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
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
                  )
                : null, // Let the AppBar handle the leading widget (show drawer button)
            title: Text(_titles[_selectedIndex]),
             actions: [
              if (widget.manager == null) const LogoutButton(),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Пользователи'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Расписание'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Табели'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Компетенции ТО'),
              onTap: () {
                Navigator.pop(context);
                handleMenuSelection('competencies');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            )
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
