import 'package:fitman_common/enums/executor_type.dart';
import 'package:json_annotation/json_annotation.dart';

class ExecutorTypeConverter implements JsonConverter<ExecutorType?, int?> {
  const ExecutorTypeConverter();

  @override
  ExecutorType? fromJson(int? json) =>
      json == null ? null : ExecutorType.values[json];

  @override
  int? toJson(ExecutorType? object) => object?.index;
}
