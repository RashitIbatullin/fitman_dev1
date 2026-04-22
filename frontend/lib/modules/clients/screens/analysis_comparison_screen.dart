import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/analysis_provider.dart';

class AnalysisComparisonScreen extends ConsumerWidget {
  final AnthropometryMeasurement first;
  final AnthropometryMeasurement second;

  const AnalysisComparisonScreen({
    super.key,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Static data (fetches once for the user)
    final somatotypeAsync = ref.watch(somatotypeStringProvider(first.userId));

    // Dynamic data (fetches for each measurement)
    final bodyShape1 = ref.watch(bodyShapeProvider(first));
    final bodyShape2 = ref.watch(bodyShapeProvider(second));
    final whtr1Async = ref.watch(whtrProfileProvider(first));
    final whtr2Async = ref.watch(whtrProfileProvider(second));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение анализов'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Static data card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Соматотип',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  somatotypeAsync.when(
                    data: (somatotype) => Text(somatotype,
                        style: Theme.of(context).textTheme.bodyLarge),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Ошибка: $e'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 32),

          // Dynamic data cards
          _DynamicComparisonCard(
            title: 'Тип фигуры',
            firstMeasurement: first,
            secondMeasurement: second,
            firstValue: bodyShape1,
            secondValue: bodyShape2,
          ),
          const SizedBox(height: 16),
          whtr1Async.when(
            data: (whtr1) => whtr2Async.when(
              data: (whtr2) => _DynamicComparisonCard(
                title: 'Индекс WHtR',
                firstMeasurement: first,
                secondMeasurement: second,
                firstValue:
                    '${whtr1.gradation} (${whtr1.ratio.toStringAsFixed(2)})',
                secondValue:
                    '${whtr2.gradation} (${whtr2.ratio.toStringAsFixed(2)})',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Ошибка: $e'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Ошибка: $e'),
          ),
          const SizedBox(height: 16),
          _MetabolicRateComparisonCard(first: first, second: second),
        ],
      ),
    );
  }
}

class _DynamicComparisonCard extends StatelessWidget {
  final String title;
  final AnthropometryMeasurement firstMeasurement;
  final AnthropometryMeasurement secondMeasurement;
  final String firstValue;
  final String secondValue;

  const _DynamicComparisonCard({
    required this.title,
    required this.firstMeasurement,
    required this.secondMeasurement,
    required this.firstValue,
    required this.secondValue,
  });

  @override
  Widget build(BuildContext context) {
    final dateStyle = Theme.of(context).textTheme.labelMedium;
    final valueStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildComparisonRow(
              context: context,
              date: firstMeasurement.dateTime,
              value: firstValue,
              dateStyle: dateStyle,
              valueStyle: valueStyle,
            ),
            const SizedBox(height: 8),
            _buildComparisonRow(
              context: context,
              date: secondMeasurement.dateTime,
              value: secondValue,
              dateStyle: dateStyle,
              valueStyle: valueStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required BuildContext context,
    required DateTime date,
    required String value,
    required TextStyle? dateStyle,
    required TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DateFormat.yMd('ru').add_jm().format(date.toLocal())}:',
          style: dateStyle,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _MetabolicRateComparisonCard extends ConsumerWidget {
  final AnthropometryMeasurement first;
  final AnthropometryMeasurement second;

  const _MetabolicRateComparisonCard({required this.first, required this.second});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (first.id == null || second.id == null) {
      return const SizedBox.shrink();
    }

    final params1 =
        MetabolicRateParams(clientId: first.userId, measurementId: first.id!);
    final params2 =
        MetabolicRateParams(clientId: second.userId, measurementId: second.id!);

    final async1 = ref.watch(metabolicRateProvider(params1));
    final async2 = ref.watch(metabolicRateProvider(params2));

    final dateStyle = Theme.of(context).textTheme.labelMedium;
    final valueStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Базовый метаболизм (BMR)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            async1.when(
              data: (data1) {
                if (data1.isEmpty) return const Text('Нет данных для замера 1');
                final bmr1 = (data1['bmr'] as double).toStringAsFixed(0);
                final tdee1 = (data1['tdee'] as double).toStringAsFixed(0);
                return _buildComparisonRow(
                  context: context,
                  date: first.dateTime,
                  value: 'BMR: $bmr1, TDEE: $tdee1 ккал',
                  dateStyle: dateStyle,
                  valueStyle: valueStyle,
                );
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text('Ошибка: $e'),
            ),
            const SizedBox(height: 8),
            async2.when(
              data: (data2) {
                if (data2.isEmpty) return const Text('Нет данных для замера 2');
                final bmr2 = (data2['bmr'] as double).toStringAsFixed(0);
                final tdee2 = (data2['tdee'] as double).toStringAsFixed(0);
                return _buildComparisonRow(
                  context: context,
                  date: second.dateTime,
                  value: 'BMR: $bmr2, TDEE: $tdee2 ккал',
                  dateStyle: dateStyle,
                  valueStyle: valueStyle,
                );
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text('Ошибка: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required BuildContext context,
    required DateTime date,
    required String value,
    required TextStyle? dateStyle,
    required TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DateFormat.yMd('ru').add_jm().format(date.toLocal())}:',
          style: dateStyle,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

