import 'package:fitman_common/custom/custom_date_time_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_movement.model.freezed.dart';
part 'group_movement.model.g.dart';

@freezed
class GroupMovement with _$GroupMovement {
  const factory GroupMovement({
    String? id,
    required String userId,
    String? fromGroupId,
    String? toGroupId,
    @CustomDateTimeConverter() required DateTime movementDate,
    String? reason,
    required String movedByUserId,
    @NullableCustomDateTimeConverter() DateTime? createdAt,
  }) = _GroupMovement;

  factory GroupMovement.fromJson(Map<String, dynamic> json) =>
      _$GroupMovementFromJson(json);
}
