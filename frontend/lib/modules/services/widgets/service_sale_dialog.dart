import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/api/services_api.dart';
import '../providers/services_provider.dart';

/// Диалог оформления услуги клиенту (менеджер или администратор).
class ServiceSaleDialog extends ConsumerStatefulWidget {
  const ServiceSaleDialog({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<ServiceSaleDialog> createState() => _ServiceSaleDialogState();
}

class _ServiceSaleDialogState extends ConsumerState<ServiceSaleDialog> {
  final TextEditingController _discountController = TextEditingController();
  String? _serviceId;
  int _paymentSource = ServicePaymentSource.cash;
  bool _saving = false;

  static const List<_PaymentSourceOption> _sources = [
    _PaymentSourceOption(ServicePaymentSource.cash, 'Касса'),
    _PaymentSourceOption(ServicePaymentSource.terminal, 'Терминал'),
    _PaymentSourceOption(ServicePaymentSource.sbp, 'СБП'),
    _PaymentSourceOption(ServicePaymentSource.external1c, '1С'),
    _PaymentSourceOption(ServicePaymentSource.none, 'Без оплаты'),
  ];

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<Service> services) async {
    final service = services.firstWhere((item) => item.id == _serviceId);
    setState(() => _saving = true);
    try {
      await ServicesApiService().createPurchase(
        clientId: widget.clientId,
        serviceId: service.id,
        paymentSource: _paymentSource,
        discount: double.tryParse(
          _discountController.text.replaceAll(',', '.'),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось оформить услугу: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(activeServicesProvider);

    return AlertDialog(
      title: const Text('Оформить услугу'),
      content: SizedBox(
        width: 420,
        child: servicesAsync.when(
          data: (services) => _buildForm(services),
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Text('Не удалось загрузить каталог: $error'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        servicesAsync.when(
          data: (services) => FilledButton(
            onPressed: _saving || services.isEmpty || _serviceId == null
                ? null
                : () => _submit(services),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Оформить'),
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildForm(List<Service> services) {
    if (services.isEmpty) {
      return const Text('В каталоге нет активных услуг');
    }

    final matches = services.where((item) => item.id == _serviceId);
    final selected = matches.isEmpty ? null : matches.first;
    final discount = double.tryParse(
          _discountController.text.replaceAll(',', '.'),
        ) ??
        0;
    final basePrice = selected?.basePrice;
    final finalPrice = basePrice == null
        ? null
        : (basePrice - discount).clamp(0, double.infinity).toDouble();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _serviceId,
            decoration: const InputDecoration(
              labelText: 'Услуга',
              border: OutlineInputBorder(),
            ),
            items: services
                .map(
                  (service) => DropdownMenuItem<String>(
                    value: service.id,
                    child: Text(
                      '${service.name} · ${_formatPrice(service.basePrice)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _serviceId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _paymentSource,
            decoration: const InputDecoration(
              labelText: 'Источник оплаты',
              border: OutlineInputBorder(),
            ),
            items: _sources
                .map(
                  (source) => DropdownMenuItem<int>(
                    value: source.value,
                    child: Text(source.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _paymentSource = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Скидка, ₽',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            Text(
              'Срок: ${selected.durationDays ?? '—'} дн.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (finalPrice != null)
              Text(
                'К оплате: ${_formatPrice(finalPrice)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
          const SizedBox(height: 8),
          Text(
            'FitMan не принимает деньги: фиксируется только факт оплаты.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return 'без стоимости';
    return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)} ₽';
  }
}

class _PaymentSourceOption {
  const _PaymentSourceOption(this.value, this.label);

  final int value;
  final String label;
}
