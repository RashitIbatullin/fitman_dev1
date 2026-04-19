import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:fitman_app/providers/auth_provider.dart';
import 'package:fitman_app/utils/body_shape_helper.dart';
import 'package:intl/intl.dart';

final somatotypeProvider =
    FutureProvider.family<Map<String, dynamic>, String?>((ref, clientId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final userRoles = user.roles.map((r) => r.name).toSet();
  final bool isStaff = userRoles.contains('admin') ||
      userRoles.contains('trainer') ||
      userRoles.contains('instructor') ||
      userRoles.contains('manager');

  if (isStaff && clientId != null) {
    return ApiService.getSomatotypeProfileForClient(clientId);
  } else {
    return ApiService.getSomatotypeProfile();
  }
});

final whtrProfilesProvider =
    FutureProvider.family<WhtrProfiles, String?>((ref, clientId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final userRoles = user.roles.map((r) => r.name).toSet();
  final bool isStaff = userRoles.contains('admin') ||
      userRoles.contains('trainer') ||
      userRoles.contains('instructor') ||
      userRoles.contains('manager');

  if (isStaff && clientId != null) {
    return ApiService.getWhtrProfilesForClient(clientId);
  } else {
    return ApiService.getWhtrProfiles();
  }
});

class AnalysisScreen extends StatelessWidget {
  final String clientId;
  final AnthropometryMeasurement measurement;

  const AnalysisScreen(
      {super.key, required this.clientId, required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Анализ фигуры')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Анализ на основе замера от ${DateFormat('dd.MM.yyyy HH:mm', 'ru').format(measurement.dateTime.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _BodyShapeCard(clientId: clientId),
          const SizedBox(height: 16),
          _SomatotypeCard(clientId: clientId),
          const SizedBox(height: 16),
          _WhtrCard(clientId: clientId),
        ],
      ),
    );
  }
}

class _BodyShapeCard extends ConsumerWidget {
  const _BodyShapeCard({required this.clientId});
  final String? clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final somatotypeAsync = ref.watch(somatotypeProvider(clientId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: somatotypeAsync.when(
          data: (data) {
            final shape = data['body_shape'] as String? ?? 'Не определен';
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Тип фигуры',
                        style: TextStyle(fontWeight: FontWeight.bold)),                    const SizedBox(height: 4),
                    Text(shape,
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.grey),
                  onPressed: () => showBodyShapeHelpDialog(context, shape),
                )
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Ошибка: $e'),
        ),
      ),
    );
  }
}

class _SomatotypeCard extends ConsumerWidget {
  const _SomatotypeCard({required this.clientId});
  final String? clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final somatotypeAsync = ref.watch(somatotypeProvider(clientId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: somatotypeAsync.when(
          data: (data) {
            final profile = data['somatotype_profile'] as String? ?? 'N/A';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Соматотип',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(profile, style: Theme.of(context).textTheme.bodyLarge),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Ошибка: $e'),
        ),
      ),
    );
  }
}

class _WhtrCard extends ConsumerWidget {
  const _WhtrCard({required this.clientId});
  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whtrAsync = ref.watch(whtrProfilesProvider(clientId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: whtrAsync.when(
          data: (profiles) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Индекс WHtR (талия/рост)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildWhtrRow('Начало:', profiles.start),
                const SizedBox(height: 8),
                _buildWhtrRow('Текущий:', profiles.finish),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Ошибка: $e'),
        ),
      ),
    );
  }

  Widget _buildWhtrRow(String title, WhtrProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text('${profile.gradation} (${profile.ratio.toStringAsFixed(2)})',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
