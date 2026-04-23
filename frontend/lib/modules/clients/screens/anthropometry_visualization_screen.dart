import 'package:fitman_common/fitman_common.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';

final visualizationDataProvider = FutureProvider.autoDispose
    .family<List<VisualizationDataPoint>, List<String>>(
        (ref, measurementIds) {
  if (measurementIds.isEmpty) {
    return Future.value([]);
  }
  return ApiService.getVisualizationData(measurementIds);
});

class AnthropometryVisualizationScreen extends ConsumerWidget {
  final List<String> measurementIds;

  const AnthropometryVisualizationScreen({super.key, required this.measurementIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(visualizationDataProvider(measurementIds));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Визуализация замеров'),
      ),
      body: asyncData.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('Нет данных для отображения.'));
          }
          // Sort data by date for correct plotting
          final sortedData = List<VisualizationDataPoint>.from(data)
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          final hasBodyComposition = sortedData.any((d) =>
              (d.fatPercentage != null && d.fatPercentage! > 0) ||
              (d.muscleMass != null && d.muscleMass! > 0));
          final hasMetabolism = sortedData.any((d) => d.bmr != null || d.tdee != null);
          final hasWhtr = sortedData.any((d) => d.whtrRatio != null);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (sortedData.length > 1)
                  Text(
                    'Динамика для ${sortedData.length} замеров',
                    style: Theme.of(context).textTheme.titleMedium,
                  )
                else
                  Text(
                    'Данные для одного замера',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 32),
                _WeightChart(data: sortedData),
                const SizedBox(height: 32),
                _CircumferencesChart(data: sortedData),
                if (hasWhtr) ...[
                  const SizedBox(height: 32),
                  _WhtrChart(data: sortedData),
                ],
                if (hasMetabolism) ...[
                  const SizedBox(height: 32),
                  _MetabolismChart(data: sortedData),
                ],
                if (hasBodyComposition) ...[
                  const SizedBox(height: 32),
                  _BodyCompositionChart(data: sortedData),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Ошибка загрузки данных: $e')),
      ),
    );
  }
}

// A base class for charts to reduce code duplication
abstract class _BaseChart extends StatelessWidget {
  final List<VisualizationDataPoint> data;
  const _BaseChart({required this.data});

  double _calculateDateInterval() {
    if (data.length < 2) return 1;
    final first = data.first.dateTime;
    final last = data.last.dateTime;
    final duration = last.difference(first);
    // Aim for about 5-6 labels on the chart
    return duration.inMilliseconds / 5;
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(DateFormat('dd.MM').format(date)),
    );
  }

  FlTitlesData get _titlesData => FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateDateInterval(),
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );
}

class _WeightChart extends _BaseChart {
  const _WeightChart({required super.data});

  @override
  Widget build(BuildContext context) {
    final spots =
        data.map((d) => FlSpot(d.dateTime.millisecondsSinceEpoch.toDouble(), d.weight)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Динамика веса, кг', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: _titlesData,
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withAlpha((255 * 0.3).round()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircumferencesChart extends _BaseChart {
  const _CircumferencesChart({required super.data});

  @override
  Widget build(BuildContext context) {
    final chartColors = [Colors.blue, Colors.orange, Colors.purple, Colors.green];
    final lines = {'Плечи': <FlSpot>[], 'Грудь': <FlSpot>[], 'Талия': <FlSpot>[], 'Бедра': <FlSpot>[]};

    for (var d in data) {
      final x = d.dateTime.millisecondsSinceEpoch.toDouble();
      lines['Плечи']!.add(FlSpot(x, d.shouldersCirc.toDouble()));
      lines['Грудь']!.add(FlSpot(x, d.breastCirc.toDouble()));
      lines['Талия']!.add(FlSpot(x, d.waistCirc.toDouble()));
      lines['Бедра']!.add(FlSpot(x, d.hipsCirc.toDouble()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Динамика обхватов, см', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: _titlesData,
              borderData: FlBorderData(show: true),
              lineBarsData: lines.entries
                  .map((entry) => LineChartBarData(
                        spots: entry.value,
                        isCurved: true,
                        color: chartColors[lines.keys.toList().indexOf(entry.key)],
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: lines.keys
                .map((key) => Row(children: [
                      Container(width: 10, height: 10, color: chartColors[lines.keys.toList().indexOf(key)]),
                      const SizedBox(width: 4),
                      Text(key)
                    ]))
                .toList()),
      ],
    );
  }
}

class _WhtrChart extends _BaseChart {
  const _WhtrChart({required super.data});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .where((d) => d.whtrRatio != null)
        .map((d) => FlSpot(d.dateTime.millisecondsSinceEpoch.toDouble(), d.whtrRatio!))
        .toList();
    if (spots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Динамика WHtR', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: _titlesData,
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.deepOrange,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetabolismChart extends _BaseChart {
  const _MetabolismChart({required super.data});

  @override
  Widget build(BuildContext context) {
    final bmrSpots = data
        .where((d) => d.bmr != null)
        .map((d) => FlSpot(d.dateTime.millisecondsSinceEpoch.toDouble(), d.bmr!))
        .toList();
    final tdeeSpots = data
        .where((d) => d.tdee != null)
        .map((d) => FlSpot(d.dateTime.millisecondsSinceEpoch.toDouble(), d.tdee!))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Динамика метаболизма, ккал', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: _titlesData,
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(spots: bmrSpots, isCurved: true, color: Colors.cyan, barWidth: 3),
                LineChartBarData(spots: tdeeSpots, isCurved: true, color: Colors.amber, barWidth: 3),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(children: [
              Container(width: 10, height: 10, color: Colors.cyan),
              const SizedBox(width: 4),
              const Text('BMR')
            ]),
            Row(children: [
              Container(width: 10, height: 10, color: Colors.amber),
              const SizedBox(width: 4),
              const Text('TDEE')
            ]),
          ],
        )
      ],
    );
  }
}

class _BodyCompositionChart extends _BaseChart {
  const _BodyCompositionChart({required super.data});

  @override
  Widget build(BuildContext context) {
    final fatSpots = data
        .where((d) => d.fatPercentage != null && d.fatPercentage! > 0)
        .map((d) => FlSpot(d.dateTime.millisecondsSinceEpoch.toDouble(), d.fatPercentage!))
        .toList();
    final muscleSpots = data
        .where((d) => d.muscleMass != null && d.muscleMass! > 0)
        .map((d) => FlSpot(d.dateTime.millisecondsSinceEpoch.toDouble(), d.muscleMass!))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Состав тела', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: _titlesData,
              borderData: FlBorderData(show: true),
              lineBarsData: [
                if (fatSpots.isNotEmpty)
                  LineChartBarData(spots: fatSpots, isCurved: false, color: Colors.red, barWidth: 3),
                if (muscleSpots.isNotEmpty)
                  LineChartBarData(spots: muscleSpots, isCurved: false, color: Colors.teal, barWidth: 3),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          if (fatSpots.isNotEmpty)
            Row(children: [
              Container(width: 10, height: 10, color: Colors.red),
              const SizedBox(width: 4),
              const Text('Жир, %')
            ]),
          if (muscleSpots.isNotEmpty)
            Row(children: [
              Container(width: 10, height: 10, color: Colors.teal),
              const SizedBox(width: 4),
              const Text('Мышцы, кг')
            ]),
        ])
      ],
    );
  }
}
