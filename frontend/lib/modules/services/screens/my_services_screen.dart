import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';
import '../../users/providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../utils/purchase_ui.dart';
import '../utils/service_category.dart';
import '../widgets/service_sale_dialog.dart';
import 'service_purchase_detail_screen.dart';
import 'services_dashboard_screen.dart';

/// Экран «Мои услуги»: дашборд остатков, сроков и статусов покупок клиента.
class MyServicesScreen extends ConsumerStatefulWidget {
  const MyServicesScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends ConsumerState<MyServicesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String? _selectedTypeCode;
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

  bool _canSell() {
    final user = ref.watch(authProvider).value?.user;
    if (user == null) {
      return false;
    }
    return user.roles.any(
      (role) => role.name == 'admin' || role.name == 'manager',
    );
  }

  void _reload() {
    ref.invalidate(clientServicesProvider(widget.clientId));
  }

  Future<void> _openSale() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => ServiceSaleDialog(clientId: widget.clientId),
    );
    if (created == true) {
      _reload();
    }
  }

  Future<void> _activate(ServicePurchase purchase) async {
    try {
      await ServicesApiService().activatePurchase(purchase.id);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Услуга «${purchase.serviceName}» активирована')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось активировать: $error')),
      );
    }
  }

  Future<void> _openDetail(ServicePurchase purchase) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ServicePurchaseDetailScreen(purchase: purchase),
      ),
    );
    if (changed == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(clientServicesProvider(widget.clientId));
    final canSell = _canSell();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои услуги'),
        actions: [
          if (canSell)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Каталог услуг',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServicesDashboardScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: canSell
          ? FloatingActionButton.extended(
              onPressed: _openSale,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Оформить услугу'),
            )
          : null,
      body: purchasesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  'Не удалось загрузить услуги: $error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _reload,
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
        data: (purchases) => _buildDashboard(purchases),
      ),
    );
  }

  Widget _buildDashboard(List<ServicePurchase> purchases) {
    final active = purchases
        .where((purchase) => !isArchivedPurchaseStatus(purchase.status))
        .toList();
    final archived = purchases
        .where((purchase) => isArchivedPurchaseStatus(purchase.status))
        .toList();
    final source = _onlyArchived ? archived : active;

    return Column(
      children: [
        _StatsCard(
          purchases: purchases,
          active: active,
          archived: archived,
          onlyArchived: _onlyArchived,
          onShowActive: () => setState(() => _onlyArchived = false),
          onShowArchived: () => setState(() => _onlyArchived = true),
        ),
        _FiltersCard(
          searchController: _searchController,
          purchases: purchases,
          selectedTypeCode: _selectedTypeCode,
          onlyArchived: _onlyArchived,
          onTypeChanged: (value) =>
              setState(() => _selectedTypeCode = value),
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
          child: _buildTabs(_applyFilters(source)),
        ),
      ],
    );
  }

  Widget _buildTabs(List<ServicePurchase> filtered) {
    return TabBarView(
      controller: _tabController,
      children: ServiceCategory.values.map((category) {
        final items = filtered
            .where((purchase) => classifyPurchase(purchase) == category)
            .toList();
        if (items.isEmpty) {
          return _EmptyTab(category: category, archived: _onlyArchived);
        }
        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            await ref.read(clientServicesProvider(widget.clientId).future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final purchase = items[index];
              return _PurchaseRow(
                purchase: purchase,
                onTap: () => _openDetail(purchase),
                onActivate: purchase.status == ServicePurchaseStatus.draft
                    ? () => _activate(purchase)
                    : null,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  List<ServicePurchase> _applyFilters(List<ServicePurchase> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((purchase) {
      final matchesType = _selectedTypeCode == null ||
          purchase.serviceTypeCode == _selectedTypeCode;
      final matchesSearch = query.isEmpty ||
          purchase.serviceName.toLowerCase().contains(query) ||
          (purchase.serviceCode ?? '').toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.purchases,
    required this.active,
    required this.archived,
    required this.onlyArchived,
    required this.onShowActive,
    required this.onShowArchived,
  });

  final List<ServicePurchase> purchases;
  final List<ServicePurchase> active;
  final List<ServicePurchase> archived;
  final bool onlyArchived;
  final VoidCallback onShowActive;
  final VoidCallback onShowArchived;

  @override
  Widget build(BuildContext context) {
    final hasUnlimited =
        active.any((p) => p.usageLimitMode == ServiceUsageLimitMode.unlimited);
    final remaining = active.fold<int>(
      0,
      (sum, purchase) => sum + (purchase.remainingUses ?? 0),
    );

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
              value: '${purchases.length}',
              color: Theme.of(context).colorScheme.primary,
              isActive: !onlyArchived,
              onTap: onShowActive,
            ),
            _StatTile(
              title: 'Активных',
              value: '${active.length}',
              color: Colors.green,
              isActive: !onlyArchived,
              onTap: onShowActive,
            ),
            _StatTile(
              title: 'Осталось занятий',
              value: hasUnlimited ? '∞' : '$remaining',
              color: Colors.blue,
              isActive: false,
              onTap: () {},
            ),
            _StatTile(
              title: 'В архиве',
              value: '${archived.length}',
              color: Colors.brown,
              isActive: onlyArchived,
              onTap: onShowArchived,
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
    required this.purchases,
    required this.selectedTypeCode,
    required this.onlyArchived,
    required this.onTypeChanged,
    required this.onArchivedChanged,
  });

  final TextEditingController searchController;
  final List<ServicePurchase> purchases;
  final String? selectedTypeCode;
  final bool onlyArchived;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<bool> onArchivedChanged;

  @override
  Widget build(BuildContext context) {
    final types = <String, String>{};
    for (final purchase in purchases) {
      final code = purchase.serviceTypeCode;
      if (code != null) {
        types[code] = purchase.serviceTypeTitle ?? code;
      }
    }

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
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(selectedTypeCode),
                    initialValue: selectedTypeCode,
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
                      ...types.entries.map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: onTypeChanged,
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

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({
    required this.purchase,
    required this.onTap,
    required this.onActivate,
  });

  final ServicePurchase purchase;
  final VoidCallback onTap;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final category = classifyPurchase(purchase);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isArchivedPurchaseStatus(purchase.status)
          ? Colors.grey.shade200
          : null,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(_categoryIcon(category), size: 20),
        ),
        title: Text(
          purchase.serviceName,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    purchase.serviceTypeTitle ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    purchaseStatusLabel(purchase.status),
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: purchaseStatusColor(purchase.status),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _InfoChip(
                  icon: Icons.confirmation_number_outlined,
                  label: purchaseRemainingLabel(purchase),
                ),
                if (purchase.actualExpiryDate != null)
                  _InfoChip(
                    icon: Icons.event_outlined,
                    label:
                        'до ${formatPurchaseDate(purchase.actualExpiryDate!)}',
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'detail':
                onTap();
                break;
              case 'activate':
                onActivate?.call();
                break;
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'detail',
              child: Text('Подробнее'),
            ),
            if (onActivate != null)
              const PopupMenuItem<String>(
                value: 'activate',
                child: Text('Активировать'),
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
  const _EmptyTab({required this.category, required this.archived});

  final ServiceCategory category;
  final bool archived;

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
              archived
                  ? 'В архиве по разделу «${category.label}» услуг нет'
                  : 'В разделе «${category.label}» услуг нет',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
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
