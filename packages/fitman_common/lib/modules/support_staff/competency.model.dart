import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/executor_type.dart';
import 'competency_level.enum.dart';

part 'competency.model.freezed.dart';
part 'competency.model.g.dart';

@freezed
class Competency with _$Competency {
  const factory Competency({
    required String id,
    required String competentId,
    required ExecutorType executorType,
    required String name,
    required CompetencyLevel level,
    String? certificateUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) = _Competency;

  factory Competency.fromJson(Map<String, dynamic> json) =>
      _$CompetencyFromJson(json);
}
