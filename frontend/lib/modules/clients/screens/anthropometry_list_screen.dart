import 'package:fitman_app/modules/clients/screens/anthropometry_detail_screen.dart';
import 'package:fitman_app/modules/clients/screens/anthropometry_edit_screen.dart';
import 'package:fitman_app/modules/clients/screens/comparison_and_recommendation_screen.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';

final showArchivedProvider = StateProvider<bool>((ref) => false);

final anthropometryListProvider =
    FutureProvider.family<List<AnthropometryMeasurement>, String?>(
        (ref, clientId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final showArchived = ref.watch(showArchivedProvider);
  final userRoles = user.roles.map((r) => r.name).toSet();
  final bool isStaff = userRoles.contains('admin') ||
      userRoles.contains('trainer') ||
      userRoles.contains('instructor') ||
      userRoles.contains('manager');

  List<AnthropometryMeasurement> measurements; // Declared here

  if (isStaff && clientId != null) {
    measurements = await ApiService.getAnthropometryMeasurementsForClient(clientId,
        includeArchived: showArchived);
  } else {
    // Clients should not see archived measurements of their own
    measurements = await ApiService.getAnthropometryMeasurements(includeArchived: false);
  }
  // Sort by dateTime in ascending order (earliest first)
  measurements.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return measurements;
});

// New provider for Fixed Anthropometry
final fixedAnthropometryProvider =
    FutureProvider.family<AnthropometryFixed?, String?>((ref, clientId) async {
  final authState = ref.watch(authProvider);
  final user = authState.asData?.value.user;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final userRoles = user.roles.map((r) => r.name).toSet();
  final bool isStaff = userRoles.contains('admin') ||
      userRoles.contains('trainer') ||
      userRoles.contains('instructor') ||
      userRoles.contains('manager');

  if (isStaff && clientId != null) {
    return ApiService.getFixedAnthropometryForClient(clientId);
  } else {
    return ApiService.getFixedAnthropometry();
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
          _selectedMeasurementIds.remove(_selectedMeasurementIds.first);
          _selectedMeasurementIds.add(measurementId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Можно выбрать только два замера. Самый старый выбор был заменен.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedMeasurementIds.remove(measurementId);
      }
    });
  }

  Future<void> _showArchiveDialog(
      String clientId, AnthropometryMeasurement measurement) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validate() {
              setState(() {
                formKey.currentState?.validate();
              });
            }

            reasonController.addListener(validate);

            return AlertDialog(
              title: Text(
                  'Архивировать замер от ${DateFormat.yMd().format(measurement.dateTime.toLocal())}?'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: reasonController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Причина архивации',
                    hintText: 'Минимум 5 символов',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Причина должна быть не менее 5 символов.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    reasonController.removeListener(validate);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: formKey.currentState?.validate() ?? false
                      ? () {
                          reasonController.removeListener(validate);
                          Navigator.of(context)
                              .pop(reasonController.text.trim());
                        }
                      : null,
                  child: const Text('Архивировать'),
                ),
              ],
            );
          },
        );
      },
    );

    if (reason == null || !mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await ApiService.archiveAnthropometryMeasurement(
          clientId, measurement.id!, reason);
      ref.invalidate(anthropometryListProvider(widget.clientId));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Замер успешно архивирован.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка архивации: $e')),
      );
    }
  }

  Future<void> _unarchiveMeasurement(
      String clientId, String measurementId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await ApiService.unarchiveAnthropometryMeasurement(
          clientId, measurementId);
      ref.invalidate(anthropometryListProvider(widget.clientId));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Замер успешно восстановлен из архива.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка восстановления из архива: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value.user;
    final currentUserId = user?.id;
    final targetClientId = widget.clientId ?? currentUserId;

    if (targetClientId == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Антропометрия')),
          body:
              const Center(child: Text('Не удалось определить ID клиента.')));
    }
    final roles = user?.roles.map((r) => r.name).toSet() ?? {};
    final canEdit = roles.contains('admin') ||
        roles.contains('trainer') ||
        roles.contains('instructor') ||
        roles.contains('manager');

    final showArchived = ref.watch(showArchivedProvider);
    final measurementsAsync =
        ref.watch(anthropometryListProvider(targetClientId));
    final bool canShowRecommendations = _selectedMeasurementIds.length == 2;

    return Scaffold(
      appBar: canEdit
          ? AppBar(
              toolbarHeight: kToolbarHeight,
              elevation: 1,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Показать архив', style: TextStyle(fontSize: 14)),
                  Switch(
                    value: showArchived,
                    onChanged: (value) {
                      ref.read(showArchivedProvider.notifier).state = value;
                      ref.invalidate(anthropometryListProvider);
                    },
                  ),
                ],
              ),
            )
          : null,
      body: measurementsAsync.when(
        data: (measurements) {
          if (measurements.isEmpty) {
            return Center(
                child: Text(showArchived
                    ? 'В архиве нет замеров.'
                    : canEdit
                        ? 'Замеры еще не были добавлены.'
                        : 'У вас еще нет ни одного замера.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: measurements.length,
                  itemBuilder: (context, index) {
                    final measurement = measurements[index];
                    final isArchived = measurement.archivedAt != null;
                    return Card(
                      color: isArchived ? Colors.grey.shade200 : null,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        leading: Checkbox(
                          value:
                              _selectedMeasurementIds.contains(measurement.id),
                          onChanged: isArchived
                              ? null
                              : (selected) {
                                  if (measurement.id != null) {
                                    _onMeasurementSelected(
                                        selected, measurement.id!);
                                  }
                                },
                        ),
                        title: Text(
                          'Замер от ${DateFormat.yMMMd('ru').add_jm().format(measurement.dateTime.toLocal())}',
                          style: TextStyle(
                              decoration: isArchived
                                  ? TextDecoration.lineThrough
                                  : null),
                        ),
                        subtitle: Text(
                            'Вес: ${measurement.weight?.toStringAsFixed(1) ?? 'N/A'} кг'),
                        trailing: canEdit
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                AnthropometryEditScreen(
                                                  measurement: measurement,
                                                  clientId: targetClientId,
                                                )));
                                  } else if (value == 'archive') {
                                    if (measurement.id != null) {
                                      _showArchiveDialog(
                                          targetClientId, measurement);
                                    }
                                  } else if (value == 'unarchive') {
                                    if (measurement.id != null) {
                                      _unarchiveMeasurement(
                                          targetClientId, measurement.id!);
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  if (!isArchived)
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Редактировать'),
                                    ),
                                  if (!isArchived)
                                    const PopupMenuItem<String>(
                                      value: 'archive',
                                      child: Text('Архивировать'),
                                    ),
                                  if (isArchived)
                                    const PopupMenuItem<String>(
                                      value: 'unarchive',
                                      child: Text('Деархивировать'),
                                    ),
                                ],
                              )
                            : null,
                        onTap: !canEdit
                            ? () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AnthropometryDetailScreen(
                                        measurement: measurement)));
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: canShowRecommendations
                          ? () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => ComparisonAndRecommendationScreen(
                                        measurementIds:
                                            _selectedMeasurementIds.toList(),
                                        clientId: targetClientId,
                                      )));
                            }
                          : null,
                      child: const Text('Сравнение и рекомендации'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }
}
