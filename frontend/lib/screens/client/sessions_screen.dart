import 'package:flutter/material.dart';
import 'package:fitman_app/models/schedule_item.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'client_preference_schedule.dart';

// 1. Modern Notifier for managing schedule state
class ScheduleNotifier extends Notifier<AsyncValue<List<ScheduleItem>>> {
  
  @override
  AsyncValue<List<ScheduleItem>> build() {
    // Return loading by default, fetch will be triggered manually
    return const AsyncValue.loading();
  }

  Future<void> fetchSchedule() async {
    state = const AsyncValue.loading();
    try {
      final schedule = await ApiService.getSchedule();
      state = AsyncValue.data(schedule);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// 2. Provider is now a NotifierProvider
final scheduleProvider = NotifierProvider<ScheduleNotifier, AsyncValue<List<ScheduleItem>>>(ScheduleNotifier.new);

// 3. Widget is a ConsumerStatefulWidget to use initState
class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {

  @override
  void initState() {
    super.initState();
    // 4. Fetch data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleProvider.notifier).fetchSchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 5. Watch the provider
    final scheduleData = ref.watch(scheduleProvider);

    return scheduleData.when(
      data: (schedule) => schedule.isEmpty
          ? _buildEmptyState(context)
          : _buildLessonsList(context, schedule),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        // Provide a button to retry fetching data
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка загрузки расписания: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(scheduleProvider.notifier).fetchSchedule(),
                child: const Text('Попробовать снова'),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildLessonsList(BuildContext context, List<ScheduleItem> schedule) {
    return RefreshIndicator(
      onRefresh: () => ref.read(scheduleProvider.notifier).fetchSchedule(),
      child: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final item = schedule[index];

          return ListTile(
            title: Text(item.trainingPlanName),
            subtitle: Text(
              DateFormat('d MMM y, HH:mm', 'ru').format(item.startTime),
            ),
            trailing: Chip(
              label: Text(item.status),
              backgroundColor: _getStatusColor(item.status),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Вам еще не назначены занятия. Заполните, пожалуйста, предпочтения по времени.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientPreferenceSchedule(),
                  ),
                );
              },
              child: const Text('Заполнить предпочтения'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:  
        return Colors.grey;
    }
  }
}
