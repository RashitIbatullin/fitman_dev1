import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:fitman_app/widgets/image_comparison_slider.dart';
import '../widgets/body_silhouette_painter.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: ImageComparisonSlider(
              before: CustomPaint(
                painter: BodySilhouettePainter(
                  measurement: measurement1,
                  height: height,
                ),
                child: Container(),
              ),
              after: CustomPaint(
                painter: BodySilhouettePainter(
                  measurement: measurement2,
                  height: height,
                ),
                child: Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
