import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:intl/intl.dart';

import 'package:fitman_app/providers/auth_provider.dart';
import '../../../utils/body_shape_helper.dart';
import 'anthropometry_list_screen.dart'; // For the anthropometryListProvider

// New Providers
final somatotypeProvider =
    FutureProvider.family<String, String?>((ref, clientId) async {
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

final recommendationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, clientId) async {
  return ApiService.getRecommendation(clientId);
});

class ComparisonAndRecommendationScreen extends ConsumerWidget {
  final List<String> measurementIds;
  final String clientId;

  const ComparisonAndRecommendationScreen(
      {super.key, required this.measurementIds, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(anthropometryListProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение и рекомендации'),
      ),
      body: measurementsAsync.when(
        data: (allMeasurements) {
          final selected = allMeasurements
              .where((m) => measurementIds.contains(m.id))
              .toList();
          if (selected.length != 2) {
            return const Center(
                child: Text('Ошибка: не удалось найти два выбранных замера.'));
          }
          // Ensure they are in order by date
          selected.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final first = selected[0];
          final second = selected[1];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(context, Colors.blue.shade300, 'Замер 1: ${DateFormat.yMMMd('ru').add_jm().format(first.dateTime.toLocal())}'),
                    const SizedBox(width: 20),
                    _buildLegendItem(context, Colors.red.shade300, 'Замер 2: ${DateFormat.yMMMd('ru').add_jm().format(second.dateTime.toLocal())}'),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),

              Text('Сравнение замеров',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildComparisonCard(first, second),
              const SizedBox(height: 24),

              Text('Анализ фигуры', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _BodyShapeCard(clientId: clientId),
              const SizedBox(height: 16),
              _WhtrCard(clientId: clientId),
              const SizedBox(height: 24),
              
              Text('Рекомендации системы',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _RecommendationView(measurement: second, clientId: clientId),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('Ошибка загрузки данных: $e')),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildComparisonCard(
      AnthropometryMeasurement first, AnthropometryMeasurement second) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildComparisonRow('Вес, кг', first.weight, second.weight),
            _buildComparisonRow(
                'Обхват плеч, см', first.shouldersCirc, second.shouldersCirc),
            _buildComparisonRow(
                'Обхват груди, см', first.breastCirc, second.breastCirc),
            _buildComparisonRow(
                'Обхват талии, см', first.waistCirc, second.waistCirc),
            _buildComparisonRow(
                'Обхват бедер, см', first.hipsCirc, second.hipsCirc),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, num? val1, num? val2) {
    final diff = (val2 ?? 0) - (val1 ?? 0);
    final diffText = diff == 0 ? '' : ' (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)})';
    final diffColor = diff > 0 ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text('${val1?.toStringAsFixed(1) ?? 'N/A'} ➞ ${val2?.toStringAsFixed(1) ?? 'N/A'}'),
              if (diff != 0) Text(diffText, style: TextStyle(color: diffColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationView extends ConsumerWidget {
  final AnthropometryMeasurement measurement;
  final String clientId;

  const _RecommendationView({required this.measurement, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recAsync = ref.watch(recommendationProvider(clientId));

    return recAsync.when(
      data: (rec) {
          const defaultMessage = 'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.';
          
          final recText = rec['client_recommendation']?.toString();

          if (recText == null || recText.contains(defaultMessage) || recText.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(defaultMessage),
              ),
            );
          }

          return _buildSingleRecommendationCard(measurement, recText);
        },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Ошибка загрузки рекомендации: $e'),
    );
  }

  Widget _buildSingleRecommendationCard(AnthropometryMeasurement measurement, String? recommendationText) {
     return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('На основе замера от ${DateFormat.yMMMd('ru').format(measurement.dateTime)}', style: const TextStyle(fontWeight: FontWeight.bold)),
               const Divider(height: 20),
              Text(recommendationText ?? 'Нет рекомендации.'),
            ],
          ),
      ),
    );
  }
}

class _BodyShapeCard extends ConsumerWidget {
  const _BodyShapeCard({required this.clientId});
  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final somatotypeAsync = ref.watch(somatotypeProvider(clientId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: somatotypeAsync.when(
          data: (shape) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Тип фигуры', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(shape, style: Theme.of(context).textTheme.titleLarge),
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
                const Text('Индекс WHtR (талия/рост)', style: TextStyle(fontWeight: FontWeight.bold)),
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
        Text('${profile.gradation} (${profile.ratio.toStringAsFixed(2)})', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
