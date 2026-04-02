import 'package:freezed_annotation/freezed_annotation.dart';

part 'anthropometry_data.model.freezed.dart';
part 'anthropometry_data.model.g.dart';

@freezed
class AnthropometryData with _$AnthropometryData {
  const factory AnthropometryData({
    required AnthropometryFixed fixed,
    required AnthropometryMeasurements start,
    required AnthropometryMeasurements finish,
  }) = _AnthropometryData;

  factory AnthropometryData.fromJson(Map<String, dynamic> json) =>
      _$AnthropometryDataFromJson(json);
}

@freezed
class AnthropometryFixed with _$AnthropometryFixed {
  const factory AnthropometryFixed({
    int? height,
    int? wristCirc,
    int? ankleCirc,
  }) = _AnthropometryFixed;

  factory AnthropometryFixed.fromJson(Map<String, dynamic> json) =>
      _$AnthropometryFixedFromJson(json);
}

@freezed
class AnthropometryMeasurements with _$AnthropometryMeasurements {
  const factory AnthropometryMeasurements({
    double? weight,
    int? shouldersCirc,
    int? breastCirc,
    int? waistCirc,
    int? hipsCirc,
    String? photo,
    DateTime? photoDateTime,
    String? profilePhoto,
    DateTime? profilePhotoDateTime,
  }) = _AnthropometryMeasurements;

  factory AnthropometryMeasurements.fromJson(Map<String, dynamic> json) =>
      _$AnthropometryMeasurementsFromJson(json);
}
