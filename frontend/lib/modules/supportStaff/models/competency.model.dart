import 'package:freezed_annotation/freezed_annotation.dart';

part 'competency.model.freezed.dart';
part 'competency.model.g.dart';

@freezed
class Competency with _$Competency {
  const factory Competency({
    required String id,
    required String staffId,
    required String name,
    required int level,
    String? certificateUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) = _Competency;

  factory Competency.fromJson(Map<String, dynamic> json) =>
      _$CompetencyFromJson(json);
}
