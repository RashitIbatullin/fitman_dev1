import 'package:fitman_common/custom/custom_date_time_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_group_replacement_employee.model.freezed.dart';
part 'training_group_replacement_employee.model.g.dart';

@freezed
class TrainingGroupReplacementEmployee with _$TrainingGroupReplacementEmployee {
  const factory TrainingGroupReplacementEmployee({
    String? id,
    required String groupId,
    String? oldEmployeeId,
    String? newEmployeeId,
    @CustomDateTimeConverter() required DateTime date,
    required String reason,
    required String initiatorId,
  }) = _TrainingGroupReplacementEmployee;

  factory TrainingGroupReplacementEmployee.fromJson(Map<String, dynamic> json) =>
      _$TrainingGroupReplacementEmployeeFromJson(json);
}
