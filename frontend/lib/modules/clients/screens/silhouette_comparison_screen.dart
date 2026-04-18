import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:fitman_app/widgets/image_comparison_slider.dart';
import '../widgets/body_silhouette_painter.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

class SilhouetteComparisonScreen extends StatelessWidget {
  final AnthropometryMeasurement measurement1;
  final AnthropometryMeasurement measurement2;
  final int? height;

  const SilhouetteComparisonScreen({
    super.key,
    required this.measurement1,
    required this.measurement2,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение силуэтов'),
      ),
      body: Column( // Use Column to stack slider and legend
        children: [
          Expanded( // Expanded to allow the slider to take available space
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: ImageComparisonSlider(
                    before: CustomPaint(
                      painter: BodySilhouettePainter(
                        measurement: measurement1,
                        height: height,
                        silhouetteColor: Colors.blue.shade300, // Color for measurement 1
                      ),
                      child: Container(),
                    ),
                    after: CustomPaint(
                      painter: BodySilhouettePainter(
                        measurement: measurement2,
                        height: height,
                        silhouetteColor: Colors.red.shade300, // Color for measurement 2
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, Colors.blue.shade300, 'Замер 1: ${DateFormat.yMMMd('ru').add_jm().format(measurement1.dateTime.toLocal())}'),
                const SizedBox(width: 20),
                _buildLegendItem(context, Colors.red.shade300, 'Замер 2: ${DateFormat.yMMMd('ru').add_jm().format(measurement2.dateTime.toLocal())}'),
              ],
            ),
          ),
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
}

