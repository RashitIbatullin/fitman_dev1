import 'package:fitman_common/fitman_common.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnthropometryVisualizationScreen extends StatelessWidget {
  final List<AnthropometryMeasurement> measurements;

  const AnthropometryVisualizationScreen({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    final sortedMeasurements = List<AnthropometryMeasurement>.from(measurements)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Check if there is any body composition data to show the chart
    final hasBodyCompositionData = sortedMeasurements.any((m) =>
        (m.fatPercentage != null && m.fatPercentage! > 0) ||
        (m.muscleMass != null && m.muscleMass! > 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Визуализация замеров'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (sortedMeasurements.length > 1)
              Text(
                'Динамика для ${sortedMeasurements.length} замеров',
                style: Theme.of(context).textTheme.titleMedium,
              )
            else
              Text(
                'Данные для одного замера',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 32),
            _WeightChart(measurements: sortedMeasurements),
            const SizedBox(height: 32),
            _CircumferencesChart(measurements: sortedMeasurements),
            if (hasBodyCompositionData) ...[
              const SizedBox(height: 32),
              _BodyCompositionChart(measurements: sortedMeasurements),
            ],
          ],
        ),
      ),
    );
  }
}

// A base class for charts to reduce code duplication
abstract class _BaseChart extends StatelessWidget {
  final List<AnthropometryMeasurement> measurements;
  const _BaseChart({required this.measurements});

  double _calculateDateInterval() {
    if (measurements.length < 2) return 1;
    final first = measurements.first.dateTime;
    final last = measurements.last.dateTime;
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
  const _WeightChart({required super.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) return const SizedBox.shrink();

    final spots = measurements.map((m) {
      return FlSpot(m.dateTime.millisecondsSinceEpoch.toDouble(), m.weight);
    }).toList();

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
                    color: Theme.of(context)
                        .primaryColor
                        .withAlpha((255 * 0.3).round()),
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
  const _CircumferencesChart({required super.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) return const SizedBox.shrink();
    
    final chartColors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.green,
    ];

    final Map<String, List<FlSpot>> lines = {
      'Плечи': [],
      'Грудь': [],
      'Талия': [],
      'Бедра': [],
    };

    for (var m in measurements) {
      final x = m.dateTime.millisecondsSinceEpoch.toDouble();
      lines['Плечи']!.add(FlSpot(x, m.shouldersCirc.toDouble()));
      lines['Грудь']!.add(FlSpot(x, m.breastCirc.toDouble()));
      lines['Талия']!.add(FlSpot(x, m.waistCirc.toDouble()));
      lines['Бедра']!.add(FlSpot(x, m.hipsCirc.toDouble()));
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
              lineBarsData: lines.entries.map((entry) {
                final index = lines.keys.toList().indexOf(entry.key);
                return LineChartBarData(
                  spots: entry.value,
                  isCurved: true,
                  color: chartColors[index % chartColors.length],
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: lines.keys.map((key) {
            final index = lines.keys.toList().indexOf(key);
            return Row(children: [
              Container(width: 10, height: 10, color: chartColors[index % chartColors.length]),
              const SizedBox(width: 4),
              Text(key)
            ]);
          }).toList(),
        ),
      ],
    );
  }
}


class _BodyCompositionChart extends _BaseChart {
  const _BodyCompositionChart({required super.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) return const SizedBox.shrink();

    final fatSpots = measurements
        .where((m) => m.fatPercentage != null && m.fatPercentage! > 0)
        .map((m) => FlSpot(m.dateTime.millisecondsSinceEpoch.toDouble(), m.fatPercentage!))
        .toList();
    
    final muscleSpots = measurements
        .where((m) => m.muscleMass != null && m.muscleMass! > 0)
        .map((m) => FlSpot(m.dateTime.millisecondsSinceEpoch.toDouble(), m.muscleMass!))
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
                  LineChartBarData(
                    spots: fatSpots,
                    isCurved: false,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                if (muscleSpots.isNotEmpty)
                  LineChartBarData(
                    spots: muscleSpots,
                    isCurved: false,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
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
          ],
        )
      ],
    );
  }
}
