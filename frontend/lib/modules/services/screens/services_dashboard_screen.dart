import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';
import '../providers/catalog_provider.dart';
import '../utils/service_category.dart';
import 'service_detail_screen.dart';
import 'service_edit_screen.dart';

/// Дашборд каталога услуг: показатели, фильтры и вкладки по направлениям.
class ServicesDashboardScreen extends ConsumerStatefulWidget {
  const ServicesDashboardScreen({super.key});

  @override
  ConsumerState<ServicesDashboardScreen> createState() =>
      _ServicesDashboardScreenState();
}

class _ServicesDashboardScreenState
    extends ConsumerState<ServicesDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedTypeId;
  bool _onlyArchived = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ServiceCategory.values.length,
      vsync: this,
    );
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _invalidate() {
    ref.invalidate(serviceCatalogProvider(false));
    ref.invalidate(serviceCatalogProvider(true));
  }

  Future<void> _openCreate() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ServiceEditScreen()),
    );
    if (saved == true) {
      _invalidate();
    }
  }

  Future<void> _openDetail(Service service) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(serviceId: service.id),
      ),
    );
    _invalidate();
  }

  Future<void> _openEdit(Service service) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceEditScreen(service: service),
      ),
    );
    if (saved == true) {
      _invalidate();
    }
  }

  Future<void> _archive(Service service) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _ArchiveServiceDialog(serviceName: service.name),
    );
    if (reason == null) {
      return;
    }

    try {
      await ServicesApiService().archiveService(service.id, reason: reason);
      if (!mounted) return;
      _invalidate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Услуга «${service.name}» в архиве')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось архивировать: $error')),
      );
    }
  }

  Future<void> _unarchive(Service service) async {
    try {
      await ServicesApiService().unarchiveService(service.id);
      if (!mounted) return;
      _invalidate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Услуга «${service.name}» восстановлена')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось восстановить: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(serviceCatalogProvider(false));
    final archivedAsync = ref.watch(serviceCatalogProvider(true));
    final typesAsync = ref.watch(serviceTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Услуги')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        tooltip: 'Добавить услугу',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _StatsCard(
            activeAsync: activeAsync,
            archivedAsync: archivedAsync,
            onlyArchived: _onlyArchived,
            onShowActive: () => setState(() => _onlyArchived = false),
            onShowArchived: () => setState(() => _onlyArchived = true),
          ),
          _FiltersCard(
            searchController: _searchController,
            typesAsync: typesAsync,
            selectedTypeId: _selectedTypeId,
            onlyArchived: _onlyArchived,
            onTypeChanged: (value) => setState(() => _selectedTypeId = value),
            onArchivedChanged: (value) =>
                setState(() => _onlyArchived = value),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: ServiceCategory.values
                .map((category) => Tab(text: category.label))
                .toList(),
          ),
          Expanded(
            child: _buildTabViews(
              activeAsync: activeAsync,
              archivedAsync: archivedAsync,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabViews({
    required AsyncValue<List<Service>> activeAsync,
    required AsyncValue<List<Service>> archivedAsync,
  }) {
    final sourceAsync = _onlyArchived ? archivedAsync : activeAsync;

    return sourceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Не удалось загрузить услуги: $error'),
        ),
      ),
      data: (items) {
        final filtered = _applyFilters(items);
        return TabBarView(
          controller: _tabController,
          children: ServiceCategory.values.map((category) {
            final categoryItems = filtered
                .where((service) => classifyService(service) == category)
                .toList();
            if (categoryItems.isEmpty) {
              return _EmptyTab(category: category);
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: categoryItems.length,
              itemBuilder: (context, index) {
                final service = categoryItems[index];
                return _ServiceRow(
                  service: service,
                  onTap: () => _openDetail(service),
                  onEdit: () => _openEdit(service),
                  onArchive: () => _archive(service),
                  onUnarchive: () => _unarchive(service),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  List<Service> _applyFilters(List<Service> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((service) {
      final matchesType =
          _selectedTypeId == null || service.serviceTypeId == _selectedTypeId;
      final matchesSearch = query.isEmpty ||
          service.name.toLowerCase().contains(query) ||
          service.code.toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.activeAsync,
    required this.archivedAsync,
    required this.onlyArchived,
    required this.onShowActive,
    required this.onShowArchived,
  });

  final AsyncValue<List<Service>> activeAsync;
  final AsyncValue<List<Service>> archivedAsync;
  final bool onlyArchived;
  final VoidCallback onShowActive;
  final VoidCallback onShowArchived;

  @override
  Widget build(BuildContext context) {
    final active = activeAsync.valueOrNull ?? const <Service>[];
    final archived = archivedAsync.valueOrNull ?? const <Service>[];
    final types = {...active.map((service) => service.serviceTypeId)}.length;
    final activeCount = active.where((service) => service.isActive).length;

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceAround,
          children: [
            _StatTile(
              title: 'Всего',
              value: '${active.length + archived.length}',
              color: Theme.of(context).colorScheme.primary,
              isActive: !onlyArchived,
              onTap: onShowActive,
            ),
            _StatTile(
              title: 'Активных',
              value: '$activeCount',
              color: Colors.green,
              isActive: !onlyArchived,
              onTap: onShowActive,
            ),
            _StatTile(
              title: 'В архиве',
              value: '${archived.length}',
              color: Colors.brown,
              isActive: onlyArchived,
              onTap: onShowArchived,
            ),
            _StatTile(
              title: 'Типов',
              value: '$types',
              color: Colors.blueGrey,
              isActive: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String value;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withAlpha((255 * 0.1).round())
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.searchController,
    required this.typesAsync,
    required this.selectedTypeId,
    required this.onlyArchived,
    required this.onTypeChanged,
    required this.onArchivedChanged,
  });

  final TextEditingController searchController;
  final AsyncValue<List<Map<String, dynamic>>> typesAsync;
  final String? selectedTypeId;
  final bool onlyArchived;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<bool> onArchivedChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Поиск по названию или коду',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: searchController.clear,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: typesAsync.when(
                    data: (types) => DropdownButtonFormField<String>(
                      key: ValueKey(selectedTypeId),
                      initialValue: selectedTypeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Тип услуги',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Все типы'),
                        ),
                        ...types.map(
                          (type) => DropdownMenuItem<String>(
                            value: type['id'] as String,
                            child: Text(
                              type['title'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: onTypeChanged,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stackTrace) =>
                        const Text('Не удалось загрузить типы'),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Архив'),
                Switch(
                  value: onlyArchived,
                  onChanged: onArchivedChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.onTap,
    required this.onEdit,
    required this.onArchive,
    required this.onUnarchive,
  });

  final Service service;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onUnarchive;

  @override
  Widget build(BuildContext context) {
    final archived = service.archivedAt != null;
    final category = classifyService(service);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: archived ? Colors.grey.shade200 : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(_categoryIcon(category), size: 20),
        ),
        title: Text(
          service.name,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${service.serviceTypeTitle} · ${service.code}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.confirmation_number_outlined,
                  label: serviceLimitLabel(service),
                ),
                if (service.durationDays != null)
                  _InfoChip(
                    icon: Icons.event_outlined,
                    label: '${service.durationDays} дн.',
                  ),
                if (archived)
                  const Chip(
                    label: Text('Архив', style: TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.brown,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                else if (!service.isActive)
                  const Chip(
                    label: Text('Снята с продажи', style: TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'archive':
                onArchive();
                break;
              case 'unarchive':
                onUnarchive();
                break;
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            if (!archived) ...[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Изменить'),
              ),
              const PopupMenuItem<String>(
                value: 'archive',
                child: Text('Архивировать'),
              ),
            ] else
              const PopupMenuItem<String>(
                value: 'unarchive',
                child: Text('Деархивировать'),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.blueGrey),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.category});

  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_categoryIcon(category), size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'В разделе «${category.label}» услуг нет',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveServiceDialog extends StatefulWidget {
  const _ArchiveServiceDialog({required this.serviceName});

  final String serviceName;

  @override
  State<_ArchiveServiceDialog> createState() => _ArchiveServiceDialogState();
}

class _ArchiveServiceDialogState extends State<_ArchiveServiceDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _reasonController.text.trim();
    if (reason.length < 5) {
      setState(() => _error = 'Причина — не менее 5 символов');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Архивировать «${widget.serviceName}»'),
      content: TextField(
        controller: _reasonController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Причина архивации',
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Архивировать'),
        ),
      ],
    );
  }
}

IconData _categoryIcon(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.training:
      return Icons.fitness_center;
    case ServiceCategory.medical:
      return Icons.medical_services_outlined;
    case ServiceCategory.cosmetology:
      return Icons.spa_outlined;
    case ServiceCategory.other:
      return Icons.miscellaneous_services_outlined;
  }
}
