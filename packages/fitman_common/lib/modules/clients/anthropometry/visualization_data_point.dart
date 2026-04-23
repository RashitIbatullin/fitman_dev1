import 'package:freezed_annotation/freezed_annotation.dart';

part 'visualization_data_point.freezed.dart';
part 'visualization_data_point.g.dart';

@freezed
class VisualizationDataPoint with _$VisualizationDataPoint {
  const factory VisualizationDataPoint({
    required DateTime dateTime,
    required double weight,
    required int shouldersCirc,
    required int breastCirc,
    required int waistCirc,
    required int hipsCirc,
    double? fatPercentage,
    double? muscleMass,
    // Calculated values
    double? whtrRatio,
    double? bmr,
    double? tdee,
  }) = _VisualizationDataPoint;

  factory VisualizationDataPoint.fromJson(Map<String, dynamic> json) =>
      _$VisualizationDataPointFromJson(json);
}
