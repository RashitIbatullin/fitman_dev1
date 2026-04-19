import 'package:fitman_app/providers/analysis_provider.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final firstAnalysis = ref.watch(singleAnalysisProvider(first.id!));
    final secondAnalysis = ref.watch(singleAnalysisProvider(second.id!));

    final headerStyle =
        Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение анализов'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDateHeader(context, headerStyle),
          const SizedBox(height: 16),
          // Comparison Cards
          firstAnalysis.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Ошибка: $err'),
            data: (firstData) => secondAnalysis.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Ошибка: $err'),
              data: (secondData) {
                return Column(
                  children: [
                    _ComparisonCard(
                      title: 'Тип фигуры',
                      firstValue: firstData.bodyShape,
                      secondValue: secondData.bodyShape,
                    ),
                    const SizedBox(height: 16),
                    _ComparisonCard(
                      title: 'Соматотип',
                      firstValue: firstData.somatotypeProfile,
                      secondValue: secondData.somatotypeProfile,
                    ),
                    const SizedBox(height: 16),
                    _ComparisonCard(
                      title: 'Индекс WHtR',
                      firstValue:
                          '${firstData.whtrProfile.gradation} (${firstData.whtrProfile.ratio.toStringAsFixed(2)})',
                      secondValue:
                          '${secondData.whtrProfile.gradation} (${secondData.whtrProfile.ratio.toStringAsFixed(2)})',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, TextStyle? headerStyle) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.yMd('ru').add_jm().format(first.dateTime.toLocal()),
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                DateFormat.yMd('ru').add_jm().format(second.dateTime.toLocal()),
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final String title;
  final String firstValue;
  final String secondValue;

  const _ComparisonCard({
    required this.title,
    required this.firstValue,
    required this.secondValue,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.bodyLarge;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: Text(firstValue,
                        style: valueStyle, textAlign: TextAlign.center)),
                const VerticalDivider(),
                Expanded(
                    child: Text(secondValue,
                        style: valueStyle, textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
