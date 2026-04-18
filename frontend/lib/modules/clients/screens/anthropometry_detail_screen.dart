import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/modules/clients/widgets/fixed_values_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../widgets/body_silhouette_painter.dart';

class AnthropometryDetailScreen extends ConsumerWidget {
  final AnthropometryMeasurement measurement;

  const AnthropometryDetailScreen({super.key, required this.measurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedDataAsync = ref.watch(fixedAnthropometryProvider(measurement.userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Замер от ${DateFormat.yMMMd('ru').format(measurement.dateTime.toLocal())}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            fixedDataAsync.when(
              data: (fixedData) => Center(
                child: SizedBox(
                  height: 350,
                  width: 200,
                  child: CustomPaint(
                    painter: BodySilhouettePainter(
                      measurement: measurement,
                      height: fixedData?.height,
                    ),
                    child: Container(),
                  ),
                ),
              ),
              loading: () => const SizedBox(
                  height: 350,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, s) => const SizedBox(
                  height: 350,
                  child: Center(child: Icon(Icons.error_outline, color: Colors.red))),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Дата замера:',
                DateFormat.yMMMd('ru').add_jm().format(measurement.dateTime.toLocal())),
            _buildDetailRow('Вес:',
                '${measurement.weight?.toStringAsFixed(1) ?? '-'} кг'),
            _buildDetailRow('Обхват плеч:',
                '${measurement.shouldersCirc?.toString() ?? '-'} см'),
            _buildDetailRow('Обхват груди:',
                '${measurement.breastCirc?.toString() ?? '-'} см'),
            _buildDetailRow('Обхват талии:',
                '${measurement.waistCirc?.toString() ?? '-'} см'),
            _buildDetailRow('Обхват бедер:',
                '${measurement.hipsCirc?.toString() ?? '-'} см'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
