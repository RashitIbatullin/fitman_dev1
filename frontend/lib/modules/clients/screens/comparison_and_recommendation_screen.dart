import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'anthropometry_list_screen.dart'; // For the provider

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
              Text('Рекомендации системы',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _RecommendationView(first: first, second: second),
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
  final AnthropometryMeasurement first;
  final AnthropometryMeasurement second;

  const _RecommendationView({required this.first, required this.second});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rec1Async = ref.watch(recommendationProvider(first.userId));
    final rec2Async = ref.watch(recommendationProvider(second.userId));

    return rec1Async.when(
      data: (rec1) => rec2Async.when(
        data: (rec2) {
          const defaultMessage = 'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.';
          
          final rec1Text = rec1['client_recommendation']?.toString();
          final rec2Text = rec2['client_recommendation']?.toString();

          final bool isRec1Default = rec1Text == null || rec1Text.contains(defaultMessage);
          final bool isRec2Default = rec2Text == null || rec2Text.contains(defaultMessage);

          if (isRec1Default && isRec2Default) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(defaultMessage),
              ),
            );
          }

          return Column(
            children: [
              if (!isRec1Default)
                _buildSingleRecommendationCard(first, rec1Text),
              if (!isRec2Default) ...[
                const SizedBox(height: 16),
                _buildSingleRecommendationCard(second, rec2Text),
              ]
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text('Ошибка загрузки рекомендации 2: $e'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Ошибка загрузки рекомендации 1: $e'),
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
