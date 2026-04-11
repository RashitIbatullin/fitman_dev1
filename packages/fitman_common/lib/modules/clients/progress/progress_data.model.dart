import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_data.model.freezed.dart';
part 'progress_data.model.g.dart';

@freezed
class ProgressData with _$ProgressData {
  const factory ProgressData({
    required List<ChartDataPoint> weight,
    required List<ChartDataPoint> calories,
    required List<ChartDataPoint> balance,
    required KpiData kpi,
    required String recommendations,
  }) = _ProgressData;

  factory ProgressData.fromJson(Map<String, dynamic> json) =>
      _$ProgressDataFromJson(json);
}

@freezed
class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    required DateTime date,
    required double value,
  }) = _ChartDataPoint;

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) =>
      _$ChartDataPointFromJson(json);
}

@freezed
class KpiData with _$KpiData {
  const factory KpiData({
    double? avgWeight,
    double? weightChange,
    int? avgCalories,
  }) = _KpiData;

  factory KpiData.fromJson(Map<String, dynamic> json) =>
      _$KpiDataFromJson(json);
}
