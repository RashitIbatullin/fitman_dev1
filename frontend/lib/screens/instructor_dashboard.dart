import 'package:fitman_app/modules/users/models/user.dart';
import 'package:fitman_app/modules/users/screens/users_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';

class InstructorDashboard extends ConsumerStatefulWidget {
  final User? instructor;
  final bool showBackButton;
  const InstructorDashboard({super.key, this.instructor, required this.showBackButton});

  @override
  ConsumerState<InstructorDashboard> createState() =>
      _InstructorDashboardState();
}

class _InstructorDashboardState extends ConsumerState<InstructorDashboard> {
  int _selectedIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<String> _titles = const [
    'Главное',
    'Профиль',
    'Пользователи',
    'Расписание',
    'Табель',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.instructor ?? ref.watch(authProvider).value?.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> views = [
      const Center(child: Text('Главное')),
      ProfileScreen(user: user),
      UsersListScreen(
        scrollController: _scrollController,
        showToolbar: false,
        initialFilter: 'client',
      ),
      const Center(child: Text('Расписание - в разработке')),
      const Center(child: Text('Табель - в разработке')),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton ? const BackButton() : Container(),
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (widget.instructor == null)
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
      body: IndexedStack(index: _selectedIndex, children: views),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главное'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Пользователи'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Расписание',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Табель',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
