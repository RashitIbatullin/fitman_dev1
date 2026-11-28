import 'package:fitman_common/fitman_common.dart';
import 'package:flutter/material.dart';

/// Статус покупки, при котором она считается архивной для клиента.
bool isArchivedPurchaseStatus(int status) {
  return status == ServicePurchaseStatus.exhausted ||
      status == ServicePurchaseStatus.expired ||
      status == ServicePurchaseStatus.cancelled ||
      status == ServicePurchaseStatus.refunded;
}

String purchaseStatusLabel(int status) {
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

Color purchaseStatusColor(int status) {
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

/// Остаток покупки: безлимит, квота текущего периода или общий лимит.
String purchaseRemainingLabel(ServicePurchase purchase) {
  if (purchase.usageLimitMode == ServiceUsageLimitMode.unlimited) {
    if (purchase.actualExpiryDate == null) {
      return 'Без ограничения по количеству';
    }
    return 'Действует до ${formatPurchaseDate(purchase.actualExpiryDate!)}';
  }

  if (purchase.usageLimitMode == ServiceUsageLimitMode.quota) {
    final used = purchase.quotaUsed ?? 0;
    final limit = purchase.quotaLimit ?? 0;
    final left = limit - used < 0 ? 0 : limit - used;
    return '${purchaseQuotaPeriodLabel(purchase.quotaPeriod)}: осталось $left из $limit';
  }

  final remaining = purchase.remainingUses ?? 0;
  final total = purchase.totalUses ?? remaining;
  return 'Осталось $remaining из $total';
}

String purchaseQuotaPeriodLabel(int? period) {
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

String formatPurchaseDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}

String formatPurchaseMoney(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}
