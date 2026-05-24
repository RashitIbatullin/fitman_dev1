import 'package:fitman_app/widgets/logout_button.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/modules/users/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/screens/shared/profile_screen.dart';
import 'package:fitman_app/modules/employees/screens/competency_screen.dart';

import '../modules/users/providers/auth_provider.dart';

class TrainerDashboard extends ConsumerStatefulWidget {
  final User? trainer;
  final bool showBackButton;
  const TrainerDashboard({super.key, this.trainer, required this.showBackButton});

  @override
  ConsumerState<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends ConsumerState<TrainerDashboard> {
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
    'Клиенты',
    'Расписание',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.trainer ?? ref.watch(authProvider).value!.user!;

    final List<Widget> views = [
      const Center(child: Text('Главное')),
      ProfileScreen(user: user),
      UserListScreen(
        scrollController: _scrollController,
        showToolbar: false,
      ),
      const Center(child: Text('Расписание - в разработке')),
    ];

    void handleMenuSelection(String value) {
      switch (value) {
        case 'main':
          _onItemTapped(0);
          break;
        case 'profile':
          _onItemTapped(1);
          break;
        case 'clients':
          _onItemTapped(2);
          break;
        case 'schedule':
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
      appBar: AppBar(
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
                    value: 'profile',
                    child: Text('Профиль'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clients',
                    child: Text('Клиенты'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'schedule',
                    child: Text('Расписание'),
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Создание новой тренировки
            },
          ),
          if (widget.trainer == null) const LogoutButton(),
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
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Клиенты'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Расписание',
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
