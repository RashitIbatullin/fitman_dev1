import 'package:freezed_annotation/freezed_annotation.dart';

part 'repair_time_standard.model.freezed.dart';
part 'repair_time_standard.model.g.dart';

/// Категория сложности ремонта
enum RepairComplexity {
  /// Низкая
  low,
  /// Средняя
  medium,
  /// Высокая
  high,
}

@freezed
class RepairTimeStandard with _$RepairTimeStandard {
  const factory RepairTimeStandard({
    String? id,
    required String name,
    required String equipmentTypeId,
    String? description,
    required double standardDurationHours,
    RepairComplexity? complexity,
     // Системные поля
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  }) = _RepairTimeStandard;

  factory RepairTimeStandard.fromJson(Map<String, dynamic> json) =>
      _$RepairTimeStandardFromJson(json);
}
