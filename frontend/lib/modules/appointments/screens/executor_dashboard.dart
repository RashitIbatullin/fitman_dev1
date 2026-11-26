import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitman_app/widgets/logout_button.dart';

import '../../../services/api/appointments_api.dart';
import '../widgets/skip_appointment_dialog.dart';

/// Кабинет исполнителя услуг: свои записи и отметки о выполнении.
class ExecutorDashboard extends ConsumerStatefulWidget {
  const ExecutorDashboard({super.key, this.executor, required this.showBackButton});

  final User? executor;
  final bool showBackButton;

  @override
  ConsumerState<ExecutorDashboard> createState() => _ExecutorDashboardState();
}

class _ExecutorDashboardState extends ConsumerState<ExecutorDashboard> {
  final AppointmentsApiService _api = AppointmentsApiService();
  late Future<List<Appointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Appointment>> _load() {
    final now = DateTime.now();
    return _api.getAppointments(
      from: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
      to: DateTime(now.year, now.month, now.day).add(const Duration(days: 30)),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _complete(Appointment appointment) async {
    try {
      await _api.complete(appointment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Услуга «${appointment.serviceName}» отмечена выполненной')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отметить: $error')),
      );
    }
  }

  Future<void> _skip(Appointment appointment) async {
    final result = await showDialog<SkipAppointmentResult>(
      context: context,
      builder: (context) => const SkipAppointmentDialog(),
    );
    if (result == null) return;

    try {
      await _api.skip(
        appointment.id,
        party: result.party,
        reason: result.reason,
        note: result.note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пропуск зафиксирован')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить пропуск: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кабинет исполнителя'),
        automaticallyImplyLeading: widget.showBackButton,
        actions: const [LogoutButton()],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error, onRetry: _refresh);
          }

          final items = snapshot.data ?? const <Appointment>[];
          final upcoming = items
              .where((item) => item.status == AppointmentStatus.scheduled)
              .toList();

          if (upcoming.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.event_available, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Записей на ближайшее время нет',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final appointment = upcoming[index];
                return _AppointmentCard(
                  appointment: appointment,
                  onComplete: () => _complete(appointment),
                  onSkip: () => _skip(appointment),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onComplete,
    required this.onSkip,
  });

  final Appointment appointment;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final start = appointment.startAt.toLocal();

    final end = appointment.durationMinutes == null
        ? null
        : start.add(Duration(minutes: appointment.durationMinutes!));

    final timeLabel = end == null
        ? _time(start)
        : '${_time(start)} – ${_time(end)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  '${_date(start)}, $timeLabel',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              appointment.serviceName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (appointment.serviceDescription != null &&
                appointment.serviceDescription!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                appointment.serviceDescription!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text(appointment.clientName ?? 'Клиент'),
              ],
            ),
            if (appointment.note != null && appointment.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.note!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.event_busy),
                  label: const Text('Пропуск'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check),
                  label: const Text('Выполнено'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _time(DateTime value) {
  final hours = value.hour.toString().padLeft(2, '0');
  final minutes = value.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

const List<String> _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

const List<String> _weekdays = [
  'понедельник', 'вторник', 'среда', 'четверг',
  'пятница', 'суббота', 'воскресенье',
];

String _date(DateTime value) =>
    '${value.day} ${_months[value.month - 1]}, ${_weekdays[value.weekday - 1]}';

class _ErrorView extends StatelessWidget {  const _ErrorView({required this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Не удалось загрузить записи',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => onRetry(), child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

