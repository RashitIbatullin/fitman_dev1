import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';
import '../utils/purchase_ui.dart';

/// Карточка просмотра оформленной услуги клиента.
class ServicePurchaseDetailScreen extends ConsumerStatefulWidget {
  const ServicePurchaseDetailScreen({super.key, required this.purchase});

  final ServicePurchase purchase;

  @override
  ConsumerState<ServicePurchaseDetailScreen> createState() =>
      _ServicePurchaseDetailScreenState();
}

class _ServicePurchaseDetailScreenState
    extends ConsumerState<ServicePurchaseDetailScreen> {
  bool _activating = false;

  Future<void> _activate() async {
    setState(() => _activating = true);
    try {
      await ServicesApiService().activatePurchase(widget.purchase.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _activating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось активировать: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchase = widget.purchase;
    final isDraft = purchase.status == ServicePurchaseStatus.draft;

    return Scaffold(
      appBar: AppBar(title: Text(purchase.serviceName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(
                        label: Text(purchaseStatusLabel(purchase.status)),
                        backgroundColor:
                            purchaseStatusColor(purchase.status),
                        labelStyle:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${purchase.serviceTypeTitle ?? ''} · ${purchase.serviceCode ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (purchase.archivedAt != null)
            Card(
              color: Colors.brown.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'В архиве',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Причина: ${purchase.archivedReason ?? 'не указана'}',
                    ),
                    Text(
                      'Дата: ${formatPurchaseDate(purchase.archivedAt!)}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Остаток и срок',
            children: [
              _DetailRow(
                label: 'Остаток',
                value: purchaseRemainingLabel(purchase),
              ),
              if (purchase.totalUses != null)
                _DetailRow(
                  label: 'Всего использований',
                  value: '${purchase.totalUses}',
                ),
              if (purchase.usageLimitMode == ServiceUsageLimitMode.quota)
                _DetailRow(
                  label: 'Квота периода',
                  value:
                      '${purchase.quotaUsed ?? 0} из ${purchase.quotaLimit ?? 0}',
                ),
              _DetailRow(
                label: 'Срок действия',
                value: purchase.actualExpiryDate == null
                    ? 'Не ограничен'
                    : formatPurchaseDate(purchase.actualExpiryDate!),
              ),
              _DetailRow(
                label: 'Оформлена',
                value: formatPurchaseDate(purchase.purchaseDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Оплата',
            children: [
              _DetailRow(
                label: 'Стоимость',
                value: purchase.finalPrice == null
                    ? 'Без стоимости'
                    : '${formatPurchaseMoney(purchase.finalPrice!)} ₽',
              ),
              _DetailRow(
                label: 'Статус оплаты',
                value: _paymentStatusLabel(purchase.paymentStatus),
              ),
              _DetailRow(
                label: 'Источник оплаты',
                value: _paymentSourceLabel(purchase.paymentSource),
              ),
            ],
          ),
          if (isDraft) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _activating ? null : _activate,
              icon: _activating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Активировать услугу'),
            ),
          ],
        ],
      ),
    );
  }

  String _paymentStatusLabel(int status) {
    switch (status) {
      case ServicePaymentStatus.paid:
        return 'Оплачено';
      case ServicePaymentStatus.debt:
        return 'Долг';
      default:
        return 'Не требуется';
    }
  }

  String _paymentSourceLabel(int? source) {
    switch (source) {
      case ServicePaymentSource.account:
        return 'Лицевой счёт';
      case ServicePaymentSource.cash:
        return 'Касса';
      case ServicePaymentSource.terminal:
        return 'Терминал';
      case ServicePaymentSource.external1c:
        return '1С';
      case ServicePaymentSource.sbp:
        return 'СБП';
      case ServicePaymentSource.none:
        return 'Без оплаты';
      default:
        return 'Не указан';
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
