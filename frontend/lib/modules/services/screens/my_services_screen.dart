import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../services/api/services_api.dart';
import '../../users/providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/service_sale_dialog.dart';

/// Экран «Мои услуги»: остатки, сроки и статусы оформленных услуг.
class MyServicesScreen extends ConsumerWidget {
  const MyServicesScreen({super.key, required this.clientId});

  final String clientId;

  bool _canSell(WidgetRef ref) {
    final user = ref.watch(authProvider).value?.user;
    if (user == null) {
      return false;
    }
    return user.roles.any(
      (role) => role.name == 'admin' || role.name == 'manager',
    );
  }

  Future<void> _openSale(BuildContext context, WidgetRef ref) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => ServiceSaleDialog(clientId: clientId),
    );
    if (created == true) {
      ref.invalidate(clientServicesProvider(clientId));
    }
  }

  Future<void> _activate(
    BuildContext context,
    WidgetRef ref,
    ServicePurchase purchase,
  ) async {
    try {
      await ServicesApiService().activatePurchase(purchase.id);
      if (!context.mounted) return;
      ref.invalidate(clientServicesProvider(clientId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Услуга «${purchase.serviceName}» активирована')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось активировать: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(clientServicesProvider(clientId));
    final canSell = _canSell(ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои услуги')),
      floatingActionButton: canSell
          ? FloatingActionButton.extended(
              onPressed: () => _openSale(context, ref),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Оформить услугу'),
            )
          : null,
      body: purchasesAsync.when(
        data: (purchases) {
          if (purchases.isEmpty) {
            return const _EmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(clientServicesProvider(clientId));
              await ref.read(clientServicesProvider(clientId).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: purchases.length,
              itemBuilder: (context, index) => _ServiceCard(
                purchase: purchases[index],
                onActivate: purchases[index].status == ServicePurchaseStatus.draft
                    ? () => _activate(context, ref, purchases[index])
                    : null,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text('Не удалось загрузить услуги: $error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(clientServicesProvider(clientId)),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.purchase, this.onActivate});

  final ServicePurchase purchase;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(purchase.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    purchase.serviceName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: _statusColor(purchase.status),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              purchase.serviceTypeTitle ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(_remainingLabel(purchase))),
              ],
            ),
            if (purchase.actualExpiryDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Срок: ${DateFormat('dd.MM.yyyy').format(purchase.actualExpiryDate!.toLocal())}',
                  ),
                ],
              ),
            ],
            if (purchase.finalPrice != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text('Стоимость: ${_formatMoney(purchase.finalPrice!)} ₽'),
                ],
              ),
            ],
            if (onActivate != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Активировать'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _remainingLabel(ServicePurchase purchase) {
    if (purchase.usageLimitMode == ServiceUsageLimitMode.unlimited) {
      return purchase.actualExpiryDate == null
          ? 'Без ограничения по количеству'
          : 'Действует до ${DateFormat('dd.MM.yyyy').format(purchase.actualExpiryDate!.toLocal())}';
    }

    if (purchase.usageLimitMode == ServiceUsageLimitMode.quota) {
      final used = purchase.quotaUsed ?? 0;
      final limit = purchase.quotaLimit ?? 0;
      final left = limit - used < 0 ? 0 : limit - used;
      final period = _quotaPeriodLabel(purchase.quotaPeriod);
      return '$period: осталось $left из $limit';
    }

    final remaining = purchase.remainingUses ?? 0;
    final total = purchase.totalUses ?? remaining;
    return 'Осталось $remaining из $total';
  }

  String _quotaPeriodLabel(int? period) {
    switch (period) {
      case ServiceQuotaPeriod.day:
        return 'Сегодня';
      case ServiceQuotaPeriod.week:
        return 'На этой неделе';
      case ServiceQuotaPeriod.month:
        return 'В этом месяце';
      default:
        return 'В текущем периоде';
    }
  }

  String _statusLabel(int status) {
    switch (status) {
      case ServicePurchaseStatus.draft:
        return 'Черновик';
      case ServicePurchaseStatus.active:
        return 'Активна';
      case ServicePurchaseStatus.frozen:
        return 'Заморожена';
      case ServicePurchaseStatus.exhausted:
        return 'Исчерпана';
      case ServicePurchaseStatus.expired:
        return 'Истекла';
      case ServicePurchaseStatus.cancelled:
        return 'Отменена';
      case ServicePurchaseStatus.refunded:
        return 'Возвращена';
      default:
        return 'Неизвестно';
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case ServicePurchaseStatus.active:
        return Colors.green;
      case ServicePurchaseStatus.frozen:
        return Colors.blue;
      case ServicePurchaseStatus.exhausted:
      case ServicePurchaseStatus.expired:
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'У вас пока нет оформленных услуг',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
