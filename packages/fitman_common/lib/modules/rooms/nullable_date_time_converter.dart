import 'package:json_annotation/json_annotation.dart';

class NullableDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    if (json is DateTime) {
      return json;
    }
    if (json is String) {
      return DateTime.tryParse(json);
    }
    // Return null or throw an exception if the type is unexpected.
    // Returning null might be safer for optional fields.
    return null;
  }

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}
