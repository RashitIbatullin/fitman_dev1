import 'package:fitman_common/enums/ExecutorType.dart';
import 'package:fitman_common/supportStaff/competency.model.dart';
import 'package:fitman_common/supportStaff/competency_level.enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitman_app/services/api_service.dart';
import '../providers/competency_provider.dart';

class CompetencyTab extends ConsumerStatefulWidget {
  final String employeeId;

  const CompetencyTab({super.key, required this.employeeId});

  @override
  ConsumerState<CompetencyTab> createState() => _CompetencyTabState();
}

class _CompetencyTabState extends ConsumerState<CompetencyTab> {
  List<Competency> _competencies = [];
  List<Competency> _originalCompetencies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialCompetencies();
    });
  }

  Future<void> _fetchInitialCompetencies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final competencies = await ref.read(employeeCompetenciesProvider(widget.employeeId).future);
      if (mounted) {
        setState(() {
          _competencies = List.from(competencies);
          _originalCompetencies = List.from(competencies);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить компетенции: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showAddCompetencyDialog() {
    final nameController = TextEditingController();
    CompetencyLevel? selectedLevel;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить компетенцию'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название компетенции'),
                autofocus: true,
              ),
              DropdownButtonFormField<CompetencyLevel>(
                initialValue: selectedLevel,
                hint: const Text('Уровень'),
                onChanged: (level) {
                  selectedLevel = level;
                },
                items: CompetencyLevel.values
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.localizedName),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Отмена'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Добавить'),
              onPressed: () {
                if (nameController.text.isNotEmpty && selectedLevel != null) {
                  final newCompetency = Competency(
                    id: '', // Empty ID signifies a new, unsaved competency
                    competentId: widget.employeeId,
                    executorType: ExecutorType.user,
                    name: nameController.text,
                    level: selectedLevel!,
                  );
                  setState(() {
                    _competencies.add(newCompetency);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final toAdd = _competencies.where((c) => c.id.isEmpty).toList();
      
      final originalIds = _originalCompetencies.map((c) => c.id).toSet();
      final currentIds = _competencies.where((c) => c.id.isNotEmpty).map((c) => c.id).toSet();
      final toDeleteIds = originalIds.difference(currentIds);

      for (final id in toDeleteIds) {
        await ApiService.deleteEmployeeCompetency(widget.employeeId, id);
      }

      for (final competency in toAdd) {
        await ApiService.addEmployeeCompetency(widget.employeeId, competency);
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Компетенции успешно сохранены'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
       if (mounted) {
        setState(() {
          _error = 'Ошибка сохранения: $e';
        });
      }
    } finally {
       await _fetchInitialCompetencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _competencies.isEmpty) {
       return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
        return Center(child: Text(_error!));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _competencies.isEmpty
                ? const Center(child: Text('Компетенции не найдены. Нажмите "+", чтобы добавить.'))
                : ListView.builder(
                    itemCount: _competencies.length,
                    itemBuilder: (context, index) {
                      final competency = _competencies[index];
                      final isNew = competency.id.isEmpty;
                      return ListTile(
                        leading: isNew ? const Icon(Icons.add_circle_outline, color: Colors.green) : null,
                        title: Text(competency.name),
                        subtitle: Text('Уровень: ${competency.level.localizedName}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _competencies.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCompetencyDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
