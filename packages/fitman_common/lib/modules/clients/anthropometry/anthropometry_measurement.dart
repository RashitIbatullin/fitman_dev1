import 'package:freezed_annotation/freezed_annotation.dart';

part 'anthropometry_measurement.freezed.dart';
part 'anthropometry_measurement.g.dart';

@freezed
class AnthropometryMeasurement with _$AnthropometryMeasurement {
  const factory AnthropometryMeasurement({
    String? id,
    required String userId,
    required DateTime dateTime,
    required double weight,
    required int shouldersCirc,
    required int breastCirc,
    required int waistCirc,
    required int hipsCirc,
    String? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? archivedAt,
    String? archivedBy,
    String? archivedReason,
  }) = _AnthropometryMeasurement;

  factory AnthropometryMeasurement.fromJson(Map<String, dynamic> json) =>
      _$AnthropometryMeasurementFromJson(json);
}
