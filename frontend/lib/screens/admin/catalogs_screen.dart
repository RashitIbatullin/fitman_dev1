import 'package:fitman_app/modules/rooms/screens/dashboard/rooms_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitman_app/modules/equipment/screens/dashboard/equipment_dashboard_screen.dart';
import 'package:fitman_app/modules/supportStaff/screens/support_staff_list_screen.dart'; // Import the SupportStaffListScreen
import 'work_schedule_screen.dart'; // Import the WorkScheduleScreen
import 'generic_catalog_screen.dart'; // Import the GenericCatalogScreen

class CatalogsScreen extends StatelessWidget {
  const CatalogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталоги'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.room),
            title: const Text('Помещения'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoomsDashboardScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Оборудование'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EquipmentDashboardScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Расписание работы центра'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkScheduleScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: const Text('Виды активности клиента'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenericCatalogScreen(
                    catalogName: 'Виды активности клиента',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_gymnastics),
            title: const Text('Уровни фитнес-подготовки'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenericCatalogScreen(
                    catalogName: 'Уровни фитнес-подготовки',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Цели тренировок'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Цели тренировок'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_walk),
            title: const Text('Виды Упражнений'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Виды Упражнений'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Типы Упражнений'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Типы Упражнений'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.accessibility), // Moved from "Типы телосложения"
            title: const Text('Упражнения'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Упражнения'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Набор упражнений'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Набор упражнений'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Планы тренировок'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Планы тренировок'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Заявки (Лид-менеджмент)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenericCatalogScreen(
                    catalogName: 'Заявки (Лид-менеджмент)',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Дежурства сотрудников'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GenericCatalogScreen(
                    catalogName: 'Дежурства сотрудников',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Квалификации'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenericCatalogScreen(catalogName: 'Квалификации'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people), // A suitable icon for staff
            title: const Text('Вспом. персонал'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportStaffListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
