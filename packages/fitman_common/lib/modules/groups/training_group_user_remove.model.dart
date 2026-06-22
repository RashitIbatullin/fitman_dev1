import 'package:fitman_common/custom/custom_date_time_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_group_user_remove.model.freezed.dart';
part 'training_group_user_remove.model.g.dart';

@freezed
class TrainingGroupUserRemove with _$TrainingGroupUserRemove {
  const factory TrainingGroupUserRemove({
    String? id,
    required String groupId,
    required String userId,
    required String userRole,
    @CustomDateTimeConverter() required DateTime removedAt,
    required String reason,
    required String initiatorId,
    @NullableCustomDateTimeConverter() DateTime? createdAt,
  }) = _TrainingGroupUserRemove;

  factory TrainingGroupUserRemove.fromJson(Map<String, dynamic> json) =>
      _$TrainingGroupUserRemoveFromJson(json);
}
