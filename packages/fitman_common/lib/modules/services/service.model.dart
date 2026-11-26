import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.model.freezed.dart';
part 'service.model.g.dart';

/// Режим ограничения услуги.
abstract final class ServiceUsageLimitMode {
  /// Безлимит: остаток не считается.
  static const int unlimited = 0;

  /// Общий лимит использований на весь срок услуги.
  static const int total = 1;

  /// Квота на календарный период (день, неделя, месяц).
  static const int quota = 2;
}

/// Период квоты услуги.
abstract final class ServiceQuotaPeriod {
  static const int day = 1;
  static const int week = 2;
  static const int month = 3;
}

/// Позиция каталога услуг.
///
/// Поведение задаётся параметрами, а не отдельными классами: сроком,
/// режимом ограничения и правилами оформления.
@freezed
class Service with _$Service {
  const factory Service({
    required String id,
    required String code,
    required String name,
    String? description,
    required String serviceTypeId,
    required String serviceTypeCode,
    required String serviceTypeTitle,
    double? basePrice,
    required String currency,
    int? durationDays,
    required int usageLimitMode,
    int? maxUses,
    int? quotaPeriod,
    int? quotaLimit,
    int? durationMinutes,
    required bool activationRequired,
    required bool allowStacking,
    required bool grantsAccess,
    required bool isActive,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
}
