import 'package:fitman_app/modules/clients/screens/anthropometry_edit_screen.dart';
import 'package:fitman_app/modules/clients/screens/recommendation_screen.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';

final anthropometryListProvider =
    FutureProvider.family<List<AnthropometryMeasurement>, String?>(
        (ref, clientId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final bool isAdmin = user.roles.any((r) => r.name == 'admin');
  if (isAdmin && clientId != null) {
    return ApiService.getAnthropometryMeasurementsForClient(clientId);
  } else {
    return ApiService.getAnthropometryMeasurements();
  }
});

class AnthropometryListScreen extends ConsumerStatefulWidget {
  final String? clientId;
  const AnthropometryListScreen({super.key, this.clientId});

  @override
  ConsumerState<AnthropometryListScreen> createState() =>
      _AnthropometryListScreenState();
}

class _AnthropometryListScreenState
    extends ConsumerState<AnthropometryListScreen> {
  final Set<String> _selectedMeasurementIds = {};

  void _onMeasurementSelected(bool? selected, String measurementId) {
    setState(() {
      if (selected == true) {
        if (_selectedMeasurementIds.length < 2) {
          _selectedMeasurementIds.add(measurementId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Можно выбрать только два замера для сравнения.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedMeasurementIds.remove(measurementId);
      }
    });
  }

  void _navigateAndRefresh(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.asData?.value.user?.id;
    final targetClientId = widget.clientId ?? currentUserId;

    if (targetClientId == null) {
      return const Center(
        child: Text('Не удалось определить ID клиента.'),
      );
    }

    final measurementsAsync =
        ref.watch(anthropometryListProvider(widget.clientId));
    final bool canShowRecommendations = _selectedMeasurementIds.length == 2;

    return measurementsAsync.when(
      data: (measurements) {
        if (measurements.isEmpty) {
          return const Center(child: Text('Замеры еще не были добавлены.'));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      leading: Checkbox(
                        value: _selectedMeasurementIds.contains(measurement.id),
                        onChanged: (selected) {
                          if (measurement.id != null) {
                            _onMeasurementSelected(selected, measurement.id!);
                          }
                        },
                      ),
                      title: Text(
                        'Замер от ${DateFormat.yMMMd('ru').add_jm().format(measurement.dateTime.toLocal())}',
                      ),
                      subtitle: Text(
                          'Вес: ${measurement.weight?.toStringAsFixed(1) ?? 'N/A'} кг'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _navigateAndRefresh(AnthropometryEditScreen(
                          measurement: measurement,
                          clientId: targetClientId,
                        ));
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: canShowRecommendations
                    ? () {
                        _navigateAndRefresh(RecommendationScreen(
                          measurementIds: _selectedMeasurementIds.toList(),
                          clientId: targetClientId,
                        ));
                      }
                    : null,
                child: const Text('Посмотреть рекомендации'),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Ошибка: $e')),
    );
  }
}
