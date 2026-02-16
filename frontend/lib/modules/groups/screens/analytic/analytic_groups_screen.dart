import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_providers.dart';
import './analytic_group_edit_screen.dart';
import '../../widgets/analytic/analytic_group_card.dart';
import '../../models/analytic_group.model.dart'; // Import for AnalyticGroup

class AnalyticGroupsScreen extends ConsumerStatefulWidget {
  const AnalyticGroupsScreen({super.key});

  @override
  ConsumerState<AnalyticGroupsScreen> createState() => _AnalyticGroupsScreenState();
}

class _AnalyticGroupsScreenState extends ConsumerState<AnalyticGroupsScreen> {
  String _searchQuery = '';
  bool? _isArchivedFilter; // null for 'All', true for 'Archived', false for 'Not Archived'
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Widget Builder Functions ---

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Аналитические группы'),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Поиск по названию',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Все (Архив)'),
            selected: _isArchivedFilter == null,
            onSelected: (selected) {
              setState(() {
                _isArchivedFilter = null;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: const Text('Архивные'),
              selected: _isArchivedFilter == true,
              onSelected: (selected) {
                setState(() {
                  _isArchivedFilter = selected ? true : null;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: const Text('Неархивные'),
              selected: _isArchivedFilter == false,
              onSelected: (selected) {
                setState(() {
                  _isArchivedFilter = selected ? false : null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(AsyncValue<List<AnalyticGroup>> groupsAsyncValue) {
    return Expanded(
      child: groupsAsyncValue.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('Нет аналитических групп, соответствующих фильтру.'));
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return AnalyticGroupCard(
                  group: group,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AnalyticGroupEditScreen(groupId: group.id?.toString()),
                      ),
                    );
                    // Refresh the list after editing
                    ref.invalidate(analyticGroupsProvider(
                      searchQuery: _searchQuery,
                      isArchived: _isArchivedFilter,
                    ));
                  },
                  onDelete: () async {
                    if (group.id == null) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Подтвердите удаление'),
                        content: Text('Вы уверены, что хотите удалить группу "${group.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Отмена'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(analyticGroupsProvider(
                        searchQuery: _searchQuery,
                        isArchived: _isArchivedFilter,
                      ).notifier).deleteAnalyticGroup(group.id!);
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      heroTag: 'analytic_groups_fab',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AnalyticGroupEditScreen(),
          ),
        );
        // Refresh the list after creating
        ref.invalidate(analyticGroupsProvider(
          searchQuery: _searchQuery,
          isArchived: _isArchivedFilter,
        ));
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticGroupsAsyncValue = ref.watch(analyticGroupsProvider(
      searchQuery: _searchQuery,
      isArchived: _isArchivedFilter,
    ));

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(),
          _buildGroupList(analyticGroupsAsyncValue),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}