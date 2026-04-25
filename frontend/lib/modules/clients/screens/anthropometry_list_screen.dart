import 'package:equatable/equatable.dart';
import 'package:fitman_app/modules/clients/screens/anthropometry_detail_screen.dart';
import 'package:fitman_app/modules/clients/screens/anthropometry_edit_screen.dart';
import 'package:fitman_app/modules/clients/screens/comparison_screen.dart';
import 'package:fitman_app/modules/clients/screens/analysis_screen.dart';
import 'package:fitman_app/modules/clients/screens/analysis_comparison_screen.dart';
import 'package:fitman_app/modules/clients/screens/system_recommendation_screen.dart';
import 'package:fitman_app/modules/clients/screens/anthropometry_visualization_screen.dart';
import 'package:fitman_common/fitman_common.dart';
import 'package:fitman_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../users/providers/auth_provider.dart';


final showArchivedProvider = StateProvider<bool>((ref) => false);

class AnthropometryListParams extends Equatable {
  final String? clientId;
  final bool includeArchived;

  const AnthropometryListParams({
    required this.clientId,
    required this.includeArchived,
  });

  @override
  List<Object?> get props => [clientId, includeArchived];
}

final anthropometryListProvider = FutureProvider.family
    <List<AnthropometryMeasurement>, AnthropometryListParams>(
        (ref, params) async {
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

  List<AnthropometryMeasurement> measurements;

  if (isStaff && params.clientId != null) {
    measurements = await ApiService.getAnthropometryMeasurementsForClient(
        params.clientId!,
        includeArchived: params.includeArchived);
  } else {
    measurements = await ApiService.getAnthropometryMeasurements(
        includeArchived: params.includeArchived);
  }

  measurements.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return measurements;
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
        _selectedMeasurementIds.add(measurementId);
      } else {
        _selectedMeasurementIds.remove(measurementId);
      }
    });
  }

  // Helper getter for the "Select All" checkbox state
  bool? _isSelectAll(List<AnthropometryMeasurement> allSelectable) {
    if (allSelectable.isEmpty || _selectedMeasurementIds.isEmpty) {
      return false;
    }
    // Efficiently check if all selectable IDs are in the selected set.
    final selectableIds = allSelectable.map((m) => m.id).toSet();
    if (_selectedMeasurementIds.containsAll(selectableIds)) {
      return true;
    }
    // Check for indeterminate state (at least one common element)
    if (_selectedMeasurementIds.any((id) => selectableIds.contains(id))) {
      return null;
    }
    return false;
  }

  // Handler for the "Select All" checkbox
  void _onSelectAll(
      bool? newValue, List<AnthropometryMeasurement> allSelectable) {
    setState(() {
      if (newValue ?? false) {
        _selectedMeasurementIds
            .addAll(allSelectable.map((m) => m.id!));
      } else {
        // When deselecting, remove only the currently visible selectable items
        _selectedMeasurementIds
            .removeAll(allSelectable.map((m) => m.id));
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
      // Invalidate both archived and non-archived states
      ref.invalidate(anthropometryListProvider(
        AnthropometryListParams(clientId: clientId, includeArchived: true),
      ));
      ref.invalidate(anthropometryListProvider(
        AnthropometryListParams(clientId: clientId, includeArchived: false),
      ));
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
      // Invalidate both archived and non-archived states
      ref.invalidate(anthropometryListProvider(
        AnthropometryListParams(clientId: clientId, includeArchived: true),
      ));
      ref.invalidate(anthropometryListProvider(
        AnthropometryListParams(clientId: clientId, includeArchived: false),
      ));
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
      return const Center(child: Text('Не удалось определить ID клиента.'));
    }
    final roles = user?.roles.map((r) => r.name).toSet() ?? {};
    final canEdit = roles.contains('admin') ||
        roles.contains('trainer') ||
        roles.contains('instructor') ||
        roles.contains('manager');

    final showArchived = ref.watch(showArchivedProvider);
    final listParams = AnthropometryListParams(
        clientId: targetClientId, includeArchived: showArchived);
    final measurementsAsync = ref.watch(anthropometryListProvider(listParams));

    return measurementsAsync.when(
      data: (measurements) {
        if (measurements.isEmpty) {
          return Center(
              child: Text(showArchived
                  ? 'В архиве нет замеров.'
                  : canEdit
                      ? 'Замеры еще не были добавлены.'
                      : 'У вас еще нет ни одного замера.'));
        }

        final selectableMeasurements =
            measurements.where((m) => m.archivedAt == null).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    tristate: true,
                    value: _isSelectAll(selectableMeasurements),
                    onChanged: (newValue) =>
                        _onSelectAll(newValue, selectableMeasurements),
                  ),
                  const Text('Выбрать все'),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    tooltip: 'Действия с выбранными',
                    enabled: _selectedMeasurementIds.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Действия'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    onSelected: (value) {
                      final selectedMeasurements = measurements
                          .where((m) => _selectedMeasurementIds.contains(m.id))
                          .toList()
                        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

                      switch (value) {
                        case 'compare':
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ComparisonScreen(
                              first: selectedMeasurements[0],
                              second: selectedMeasurements[1],
                            ),
                          ));
                          break;
                        case 'analyze':
                          if (selectedMeasurements.length == 1) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AnalysisScreen(
                                measurement: selectedMeasurements[0],
                              ),
                            ));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AnalysisComparisonScreen(
                                first: selectedMeasurements[0],
                                second: selectedMeasurements[1],
                              ),
                            ));
                          }
                          break;
                        case 'visualize':
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AnthropometryVisualizationScreen(
                              measurementIds: _selectedMeasurementIds.toList(),
                            ),
                          ));
                          break;
                        case 'recommend':
                          final latestMeasurement = selectedMeasurements.reduce(
                              (a, b) => a.dateTime.isAfter(b.dateTime) ? a : b);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SystemRecommendationScreen(
                              measurement: latestMeasurement,
                              clientId: targetClientId,
                            ),
                          ));
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'compare',
                        enabled: _selectedMeasurementIds.length == 2,
                        child: const Text('Сравнение'),
                      ),
                      PopupMenuItem<String>(
                        value: 'analyze',
                        enabled: _selectedMeasurementIds.length == 1 ||
                            _selectedMeasurementIds.length == 2,
                        child: const Text('Анализ'),
                      ),
                      PopupMenuItem<String>(
                        value: 'visualize',
                        enabled: _selectedMeasurementIds.isNotEmpty,
                        child: const Text('Визуализация'),
                      ),
                      PopupMenuItem<String>(
                        value: 'recommend',
                        enabled: _selectedMeasurementIds.isNotEmpty,
                        child: const Text('Рекомендации'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
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
                        DateFormat.yMMMd('ru').add_jm().format(measurement.dateTime.toLocal()),
                        style: TextStyle(
                            decoration: isArchived
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                      subtitle: Text(
                          'Вес: ${measurement.weight.toStringAsFixed(1)} кг'),
                      trailing: canEdit
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.of(context).push(MaterialPageRoute(
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
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AnthropometryDetailScreen(
                                measurement: measurement)));
                      },
                    ),
                  );
                },
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

