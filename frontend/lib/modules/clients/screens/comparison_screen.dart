import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComparisonScreen extends StatelessWidget {
  final AnthropometryMeasurement first;
  final AnthropometryMeasurement second;

  const ComparisonScreen({super.key, required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сравнение замеров')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20.0, // Horizontal space
              runSpacing: 8.0, // Vertical space between lines
              children: [
                _buildLegendItem(context, Colors.blue.shade300,
                    'Замер 1: ${DateFormat.yMMMd('ru').add_jm().format(first.dateTime.toLocal())}'),
                _buildLegendItem(context, Colors.red.shade300,
                    'Замер 2: ${DateFormat.yMMMd('ru').add_jm().format(second.dateTime.toLocal())}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonCard(first, second),
        ],
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
            const Divider(),
            _buildComparisonRow(
                'Процент жира, %', first.fatPercentage, second.fatPercentage),
            _buildComparisonRow(
                'Мышечная масса, кг', first.muscleMass, second.muscleMass),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, num? val1, num? val2) {
    final diff = (val2 ?? 0) - (val1 ?? 0);
    final diffText =
        diff == 0 ? '' : ' (${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)})';
    final diffColor = diff > 0 ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(
                  '${val1?.toStringAsFixed(1) ?? 'N/A'} ➞ ${val2?.toStringAsFixed(1) ?? 'N/A'}'),
              if (diff != 0)
                Text(diffText,
                    style: TextStyle(
                        color: diffColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
