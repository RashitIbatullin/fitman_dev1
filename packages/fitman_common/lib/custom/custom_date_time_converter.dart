import 'package:json_annotation/json_annotation.dart';

/// A [JsonConverter] that handles conversion between [DateTime] and [Object].
///
/// This converter is robust against values that might already be [DateTime] objects
/// instead of the expected ISO 8601 string.
class CustomDateTimeConverter implements JsonConverter<DateTime, Object> {
  const CustomDateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is String) {
      return DateTime.parse(json);
    }
    // The json_serializable builder can sometimes pass a DateTime object directly.
    // This happens if the value is not a string but matches the type.
    if (json is DateTime) {
      return json;
    }
    // Handle cases where the backend might send a Unix timestamp (milliseconds).
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    
    throw ArgumentError.value(
      json,
      'json',
      'Cannot be converted to DateTime',
    );
  }

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

/// A nullable version of the [CustomDateTimeConverter].
class NullableCustomDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const NullableCustomDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    if (json is String) {
      return DateTime.tryParse(json);
    }
    if (json is DateTime) {
      return json;
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    
    throw ArgumentError.value(
      json,
      'json',
      'Cannot be converted to DateTime',
    );
  }

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}
