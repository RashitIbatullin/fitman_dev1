import 'package:freezed_annotation/freezed_annotation.dart';

part 'anthropometry_fixed.freezed.dart';
part 'anthropometry_fixed.g.dart';

@freezed
class AnthropometryFixed with _$AnthropometryFixed {
  const factory AnthropometryFixed({
    required String userId,
    int? height,
    int? wristCirc,
    int? ankleCirc,
    String? companyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _AnthropometryFixed;

  factory AnthropometryFixed.fromJson(Map<String, dynamic> json) =>
      _$AnthropometryFixedFromJson(json);
}
