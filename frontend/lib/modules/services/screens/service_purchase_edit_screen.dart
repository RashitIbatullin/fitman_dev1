import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';
import '../utils/purchase_ui.dart';

/// Карточка редактирования покупки для сотрудника.
///
/// Меняется только факт оплаты: цена, срок и остаток зафиксированы
/// при оформлении и не редактируются.
class ServicePurchaseEditScreen extends ConsumerStatefulWidget {
  const ServicePurchaseEditScreen({super.key, required this.purchase});

  final ServicePurchase purchase;

  @override
  ConsumerState<ServicePurchaseEditScreen> createState() =>
      _ServicePurchaseEditScreenState();
}

class _ServicePurchaseEditScreenState
    extends ConsumerState<ServicePurchaseEditScreen> {
  late int _paymentStatus;
  int? _paymentSource;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _paymentStatus = widget.purchase.paymentStatus;
    _paymentSource = widget.purchase.paymentSource;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ServicesApiService().updatePurchase(
        widget.purchase.id,
        paymentStatus: _paymentStatus,
        paymentSource: _paymentSource,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchase = widget.purchase;

    return Scaffold(
      appBar: AppBar(title: const Text('Изменить покупку')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.serviceName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${purchase.serviceTypeTitle ?? ''} · ${purchase.serviceCode ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  _ReadOnlyRow(
                    label: 'Остаток',
                    value: purchaseRemainingLabel(purchase),
                  ),
                  _ReadOnlyRow(
                    label: 'Срок',
                    value: purchase.actualExpiryDate == null
                        ? 'Не ограничен'
                        : formatPurchaseDate(purchase.actualExpiryDate!),
                  ),
                  _ReadOnlyRow(
                    label: 'Стоимость',
                    value: purchase.finalPrice == null
                        ? 'Без стоимости'
                        : '${formatPurchaseMoney(purchase.finalPrice!)} ₽',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Оплата',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _paymentStatus,
                    decoration: const InputDecoration(
                      labelText: 'Статус оплаты',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<int>(
                        value: ServicePaymentStatus.notRequired,
                        child: Text('Не требуется'),
                      ),
                      DropdownMenuItem<int>(
                        value: ServicePaymentStatus.paid,
                        child: Text('Оплачено'),
                      ),
                      DropdownMenuItem<int>(
                        value: ServicePaymentStatus.debt,
                        child: Text('Долг'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _paymentSource,
                    decoration: const InputDecoration(
                      labelText: 'Источник оплаты',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Не указан'),
                      ),
                      DropdownMenuItem<int?>(
                        value: ServicePaymentSource.cash,
                        child: Text('Касса'),
                      ),
                      DropdownMenuItem<int?>(
                        value: ServicePaymentSource.terminal,
                        child: Text('Терминал'),
                      ),
                      DropdownMenuItem<int?>(
                        value: ServicePaymentSource.sbp,
                        child: Text('СБП'),
                      ),
                      DropdownMenuItem<int?>(
                        value: ServicePaymentSource.external1c,
                        child: Text('1С'),
                      ),
                      DropdownMenuItem<int?>(
                        value: ServicePaymentSource.none,
                        child: Text('Без оплаты'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _paymentSource = value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Цена, срок и остаток зафиксированы при оформлении. '
                    'Меняется только запись о факте оплаты.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
