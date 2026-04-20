import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/utils/body_shape_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/analysis_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  final AnthropometryMeasurement measurement;

  const AnalysisScreen({
    super.key,
    required this.measurement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all the individual providers
    final somatotypeAsync =
        ref.watch(somatotypeStringProvider(measurement.userId));
    final bodyShape = ref.watch(bodyShapeProvider(measurement)); // This one is sync
    final whtrAsync = ref.watch(whtrProfileProvider(measurement));

    return Scaffold(
      appBar: AppBar(title: const Text('Анализ фигуры')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Анализ на основе замера от ${DateFormat('dd.MM.yyyy HH:mm', 'ru').format(measurement.dateTime.toLocal())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Card for Somatotype (async provider)
          somatotypeAsync.when(
            data: (somatotype) => _SomatotypeCard(somatotypeProfile: somatotype),
            loading: () => Card(
                child: Center(
                    child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ))),
            error: (e, s) => Card(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Ошибка: $e'),
            )),
          ),
          const SizedBox(height: 16),

          // Card for Body Shape (sync provider)
          _BodyShapeCard(bodyShape: bodyShape),
          const SizedBox(height: 16),

          // Card for WHtR (async provider)
          whtrAsync.when(
            data: (whtr) => _WhtrCard(whtrProfile: whtr),
            loading: () => Card(
                child: Center(
                    child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ))),
            error: (e, s) => Card(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Ошибка: $e'),
            )),
          ),
        ],
      ),
    );
  }
}

class _BodyShapeCard extends StatelessWidget {
  const _BodyShapeCard({required this.bodyShape});
  final String bodyShape;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Тип фигуры',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(bodyShape, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.grey),
              onPressed: () => showBodyShapeHelpDialog(context, bodyShape),
            )
          ],
        ),
      ),
    );
  }
}

class _SomatotypeCard extends StatelessWidget {
  const _SomatotypeCard({required this.somatotypeProfile});
  final String somatotypeProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Соматотип',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(somatotypeProfile,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _WhtrCard extends StatelessWidget {
  const _WhtrCard({required this.whtrProfile});
  final WhtrProfile whtrProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Индекс WHtR (талия/рост)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Значение:'),
                Text(
                    '${whtrProfile.gradation} (${whtrProfile.ratio.toStringAsFixed(2)})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
