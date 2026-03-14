import 'package:freezed_annotation/freezed_annotation.dart';

part 'available_executor.model.freezed.dart';
part 'available_executor.model.g.dart';

@freezed
class AvailableExecutorsResponse with _$AvailableExecutorsResponse {
  const factory AvailableExecutorsResponse({
    required List<Executor> users,
    required List<Executor> staff,
  }) = _AvailableExecutorsResponse;

  factory AvailableExecutorsResponse.fromJson(Map<String, dynamic> json) =>
      _$AvailableExecutorsResponseFromJson(json);
}

@freezed
class Executor with _$Executor {
  const factory Executor({
    required String id,
    String? firstName,
    String? lastName,
  }) = _Executor;

  factory Executor.fromJson(Map<String, dynamic> json) =>
      _$ExecutorFromJson(json);
}
