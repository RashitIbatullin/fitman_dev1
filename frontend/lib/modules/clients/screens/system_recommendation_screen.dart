import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:intl/intl.dart';

final recommendationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, clientId) async {
  return ApiService.getRecommendation(clientId);
});

class SystemRecommendationScreen extends ConsumerWidget {
  final AnthropometryMeasurement measurement;
  final String clientId;

  const SystemRecommendationScreen(
      {super.key, required this.measurement, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рекомендации системы')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _RecommendationView(
          measurement: measurement,
          clientId: clientId,
        ),
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
        const defaultMessage =
            'Не удалось подобрать индивидуальную рекомендацию. Обратитесь к тренеру.';

        final recText = rec['client_recommendation']?.toString();

        if (recText == null ||
            recText.contains(defaultMessage) ||
            recText.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(defaultMessage),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'На основе замера от ${DateFormat.yMMMd('ru').format(measurement.dateTime)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Divider(height: 20),
                Text(recText),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Ошибка загрузки рекомендации: $e'),
    );
  }
}
