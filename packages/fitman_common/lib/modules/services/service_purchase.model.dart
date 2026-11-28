import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_purchase.model.freezed.dart';
part 'service_purchase.model.g.dart';

/// Статусы оформленной услуги.
abstract final class ServicePurchaseStatus {
  static const int draft = 0;
  static const int active = 1;
  static const int frozen = 2;
  static const int exhausted = 3;
  static const int expired = 4;
  static const int cancelled = 5;
  static const int refunded = 6;
}

/// Статус оплаты оформления. FitMan фиксирует факт, но денег не принимает.
abstract final class ServicePaymentStatus {
  static const int notRequired = 0;
  static const int paid = 1;
  static const int debt = 2;
}

/// Источник оплаты: деньги принимаются вне FitMan.
abstract final class ServicePaymentSource {
  static const int account = 1;
  static const int cash = 2;
  static const int terminal = 3;
  static const int external1c = 4;
  static const int none = 5;

  /// СБП: оплата прошла во внешней системе, в FitMan только запись факта.
  static const int sbp = 6;
}

/// Оформленная услуга клиента: срок, остаток, цена и статус.
///
/// Остаток (`remainingUses`) — производная от журнала списаний;
/// для безлимитной услуги он `null`.
@freezed
class ServicePurchase with _$ServicePurchase {
  const factory ServicePurchase({
    required String id,
    required String clientId,
    String? clientName,
    required String serviceId,
    required String serviceName,
    String? serviceCode,
    String? serviceTypeCode,
    String? serviceTypeTitle,
    String? executorSpecializationCode,
    String? executorSpecializationTitle,
    double? purchasePrice,
    required double discountPercent,
    required double discountAmount,
    double? finalPrice,
    required int paymentStatus,
    int? paymentSource,
    required DateTime purchaseDate,
    DateTime? activationDate,
    DateTime? expiryDate,
    DateTime? actualExpiryDate,
    int? totalUses,
    required int usedUses,
    int? remainingUses,
    required int status,
    int? quotaUsed,
    int? quotaLimit,
    int? quotaPeriod,
    DateTime? quotaPeriodStart,
    DateTime? quotaPeriodEnd,
    required int usageLimitMode,
  }) = _ServicePurchase;

  factory ServicePurchase.fromJson(Map<String, dynamic> json) =>
      _$ServicePurchaseFromJson(json);
}
