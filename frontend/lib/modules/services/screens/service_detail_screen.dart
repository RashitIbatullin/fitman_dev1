import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/catalog_provider.dart';
import '../utils/service_category.dart';
import 'service_edit_screen.dart';

/// Карточка просмотра услуги.
class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    Service service,
  ) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceEditScreen(service: service),
      ),
    );
    if (saved == true) {
      ref.invalidate(serviceByIdProvider(serviceId));
      ref.invalidate(serviceCatalogProvider(false));
      ref.invalidate(serviceCatalogProvider(true));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceByIdProvider(serviceId));

    return Scaffold(
      appBar: AppBar(
        title: serviceAsync.when(
          data: (service) => Text(service.name),
          loading: () => const Text('Услуга'),
          error: (error, stackTrace) => const Text('Услуга'),
        ),
        actions: [
          serviceAsync.when(
            data: (service) => IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Изменить',
              onPressed: () => _openEdit(context, ref, service),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: serviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить услугу: $error'),
          ),
        ),
        data: (service) => _ServiceDetails(service: service),
      ),
    );
  }
}

class _ServiceDetails extends StatelessWidget {
  const _ServiceDetails({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final archived = service.archivedAt != null;

    return ListView(
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
                    CircleAvatar(
                      child: Icon(_categoryIcon(classifyService(service))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${service.code} · ${service.serviceTypeTitle}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (archived)
                      const Chip(
                        label: Text('Архив'),
                        backgroundColor: Colors.brown,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    else
                      Chip(
                        label: Text(service.isActive ? 'Активна' : 'Не активна'),
                        backgroundColor:
                            service.isActive ? Colors.green : Colors.grey,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                if (service.description != null &&
                    service.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(service.description!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Параметры',
          children: [
            _DetailRow(
              label: 'Стоимость',
              value: service.basePrice == null
                  ? 'Без стоимости'
                  : '${_money(service.basePrice!)} ${service.currency}',
            ),
            _DetailRow(
              label: 'Срок действия',
              value: service.durationDays == null
                  ? 'Не ограничен'
                  : '${service.durationDays} дней',
            ),
            _DetailRow(label: 'Ограничение', value: serviceLimitLabel(service)),
            if (service.usageLimitMode == ServiceUsageLimitMode.quota)
              _DetailRow(
                label: 'Квота',
                value:
                    '${service.quotaLimit} за ${_quotaPeriod(service.quotaPeriod)}',
              ),
            if (service.durationMinutes != null)
              _DetailRow(
                label: 'Длительность сеанса',
                value: '${service.durationMinutes} мин.',
              ),
            if (service.executorSpecializationTitle != null)
              _DetailRow(
                label: 'Специализация',
                value: service.executorSpecializationTitle!,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: 'Правила',
          children: [
            _DetailRow(
              label: 'Активация',
              value: service.activationRequired
                  ? 'Отложенная (вручную)'
                  : 'Сразу при оформлении',
            ),
            _DetailRow(
              label: 'Несколько покупок',
              value: service.allowStacking ? 'Разрешены' : 'Запрещены',
            ),
            _DetailRow(
              label: 'Право доступа',
              value: service.grantsAccess ? 'Да' : 'Нет (сбор/сертификат)',
            ),
          ],
        ),
        if (archived && service.archivedReason != null) ...[
          const SizedBox(height: 12),
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
                  Text('Причина: ${service.archivedReason}'),
                  if (service.archivedAt != null)
                    Text(
                      'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(service.archivedAt!.toLocal())}',
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _money(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  String _quotaPeriod(int? period) {
    switch (period) {
      case ServiceQuotaPeriod.day:
        return 'день';
      case ServiceQuotaPeriod.week:
        return 'неделю';
      case ServiceQuotaPeriod.month:
        return 'месяц';
      default:
        return 'период';
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
