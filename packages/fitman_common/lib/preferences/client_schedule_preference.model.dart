import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_schedule_preference.model.freezed.dart';
part 'client_schedule_preference.model.g.dart';

@freezed
class ClientSchedulePreference with _$ClientSchedulePreference {
  const factory ClientSchedulePreference({
    int? id,
    required int clientId,
    required int dayOfWeek,
    required String preferredStartTime,
    required String preferredEndTime,
  }) = _ClientSchedulePreference;

  factory ClientSchedulePreference.fromJson(Map<String, dynamic> json) =>
      _$ClientSchedulePreferenceFromJson(json);
}
