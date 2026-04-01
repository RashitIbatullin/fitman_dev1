import 'package:freezed_annotation/freezed_annotation.dart';

part 'calorie_tracking_data.model.freezed.dart';
part 'calorie_tracking_data.model.g.dart';

@freezed
class CalorieTrackingData with _$CalorieTrackingData {
  const factory CalorieTrackingData({
    required DateTime date,
    required String training,
    required int consumed,
    required int burned,
    required int balance,
  }) = _CalorieTrackingData;

  factory CalorieTrackingData.fromJson(Map<String, dynamic> json) =>
      _$CalorieTrackingDataFromJson(json);
}
