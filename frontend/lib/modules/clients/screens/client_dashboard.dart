import 'package:fl_chart/fl_chart.dart';

import '../../../screens/shared/profile_screen.dart';
import '../../../widgets/logout_button.dart';
import '../../users/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fitman_common/fitman_common.dart';
import 'my_trainer_screen.dart';
import 'my_instructor_screen.dart';
import 'my_manager_screen.dart';
import 'anthropometry_screen.dart';
import 'sessions_screen.dart';
import 'calorie_tracking_screen.dart';
import 'progress_screen.dart';
import '../../chat/screens/chat_list_screen.dart';

final clientDashboardIndexProvider = StateProvider<int>((ref) => 0);

class ClientDashboard extends ConsumerWidget {
  final User? client;
  final bool showBackButton;

  const ClientDashboard({super.key, this.client, required this.showBackButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The null check is removed because AuthNavigator now guarantees a non-null user.
    final user = client ?? ref.watch(authProvider).value!.user!;

    // Now we pass the user ID to the family provider.
    final dashboardData = ref.watch(dashboardDataProvider(user.id));
    final selectedIndex = ref.watch(clientDashboardIndexProvider);

    final List<String> titles = [
      user.fullName, // Используем ФИО пользователя
      'Профиль',
      'Мой тренер',
      'Мой инструктор',
      'Мой менеджер',
      'Антропометрия',
      'Занятия',
      'Калории',
      'Прогресс',
      'Чаты', // New menu item
    ];

    final List<Widget> views = [
      // Главное - это основное содержимое дашборда
      dashboardData.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardDataProvider(user.id).future),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (data.nextTraining != null)
                _buildNextTrainingWidget(context, data.nextTraining!),
              const SizedBox(height: 16),
              // Add the new progress chart here
              _ProgressChart(measurements: data.recentMeasurements ?? []),
              const SizedBox(height: 16),
              if (data.trainingProgress != null)
                _buildTrainingProgressWidget(context, data.trainingProgress!),
              const SizedBox(height: 16),
              if (data.goalProgress != null)
                _buildGoalProgressWidget(context, data.goalProgress!),
              const SizedBox(height: 16),
              _buildAchievementsWidget(context, data.achievements),
              const SizedBox(height: 16),
              _buildQuickMenu(context, ref),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Ошибка: $error')),
      ),
      ProfileScreen(user: user), // Профиль
      const MyTrainerScreen(),
      const MyInstructorScreen(),
      const MyManagerScreen(),
      AnthropometryScreen(clientId: user.id.toString(), isEmbedded: true),
      const SessionsScreen(),
      const CalorieTrackingScreen(),
      const ProgressScreen(),
      const ChatListScreen(), // New chat list screen
    ];

    return Scaffold(
      appBar: AppBar(
        leading: showBackButton ? const BackButton() : null,
        title: Text(titles[selectedIndex]),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          if (client == null) const LogoutButton(),
          if (showBackButton)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                user.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Главное'),
              selected: selectedIndex == 0,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 0;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Профиль'),
              selected: selectedIndex == 1,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 1;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_baseball),
              title: const Text('Тренер'),
              selected: selectedIndex == 2,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 2;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_handball),
              title: const Text('Инструктор'),
              selected: selectedIndex == 3,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 3;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center),
              title: const Text('Менеджер'),
              selected: selectedIndex == 4,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 4;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.accessibility),
              title: const Text('Антропометрия'),
              selected: selectedIndex == 5,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 5;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Занятия'),
              selected: selectedIndex == 6,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 6;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Калории'),
              selected: selectedIndex == 7,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 7;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Прогресс'),
              selected: selectedIndex == 8,
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 8;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble),
              title: const Text('Чаты'),
              selected: selectedIndex == 9, // New index for chats
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 9; // New index for chats
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: selectedIndex, children: views),
    );
  }

  Widget _buildNextTrainingWidget(BuildContext context, NextTraining data) {
    final duration = data.time.difference(DateTime.now());
    final formattedDuration = duration.isNegative
        ? 'Прошло'
        : '${duration.inHours} ч ${duration.inMinutes.remainder(60)} мин';

    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.watch_later_outlined,
          color: Colors.orange,
          size: 40,
        ),
        title: Text(data.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('d MMM y, HH:mm', 'ru').format(data.time)),
            Text('До начала: $formattedDuration'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }

  Widget _buildTrainingProgressWidget(
    BuildContext context,
    TrainingProgress data,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Прогресс тренировок',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressItem(
                  context,
                  'Завершено',
                  '${data.completed}/${data.total}',
                ),
                _buildProgressItem(
                  context,
                  'Сожжено ккал',
                  data.caloriesBurned.toString(),
                ),
                _buildProgressItem(
                  context,
                  'Посещаемость',
                  '${data.attendance}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressWidget(BuildContext context, GoalProgress data) {
    final progress =
        (data.targetWeight - data.currentWeight).abs() /
            (data.targetWeight - 85).abs(); // Assuming starting weight is 85

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Прогресс по цели: ${data.goal}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${data.currentWeight}/${data.targetWeight} кг',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsWidget(
    BuildContext context,
    List<Achievement> data,
  ) {
    final iconMap = {
      'star': Icons.star,
      'local_fire_department': Icons.local_fire_department,
      'fitness_center': Icons.fitness_center,
    };
    final colorMap = {
      'amber': Colors.amber,
      'red': Colors.red,
      'blue': Colors.blue,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Достижения', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data
                  .map(
                    (ach) => Icon(
                      iconMap[ach.icon],
                      color: colorMap[ach.color],
                      size: 40,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                ref.read(clientDashboardIndexProvider.notifier).state = 6;
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text('Занятия'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text('Учет калорий'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(BuildContext context, String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<AnthropometryMeasurement> measurements;
  const _ProgressChart({required this.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Недостаточно данных для построения графика прогресса.'),
          ),
        ),
      );
    }
    
    final sorted = List<AnthropometryMeasurement>.from(measurements)..sort((a,b) => a.dateTime.compareTo(b.dateTime));

    final weightColor = Theme.of(context).primaryColor;
    final waistColor = Colors.orange;

    final weightSpots = sorted
        .map((m) => FlSpot(m.dateTime.millisecondsSinceEpoch.toDouble(), m.weight))
        .toList();
    final waistSpots = sorted
        .map((m) => FlSpot(m.dateTime.millisecondsSinceEpoch.toDouble(), m.waistCirc.toDouble()))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Динамика прогресса', style: Theme.of(context).textTheme.titleLarge),
             const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 20,
              child: LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Weight Line
                    LineChartBarData(
                      spots: weightSpots,
                      isCurved: false,
                      color: weightColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Waist Line
                    LineChartBarData(
                      spots: waistSpots,
                      isCurved: false,
                      color: waistColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  // Handling two Y-axes requires a bit more setup;
                  // For a simple dashboard view, we can normalize the data or show them separately.
                  // Given the goal of a quick glance, let's normalize for simplicity.
                  // This part is complex, will simplify for now by not using dual-axis
                  // and relying on the user to understand the trend.
                  // A proper implementation would use a library that supports dual-axis
                  // or manual calculation to map both to a 0-1 range.
                ),
              ),
            ),
             const SizedBox(height: 12),
             Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, color: weightColor),
                      const SizedBox(width: 4),
                      const Text('Вес, кг'),
                    ],
                  ),
                  const SizedBox(width: 16),
                   Row(
                    children: [
                      Container(width: 10, height: 10, color: waistColor),
                      const SizedBox(width: 4),
                      const Text('Талия, см'),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
