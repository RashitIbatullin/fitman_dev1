import 'package:freezed_annotation/freezed_annotation.dart';

/// A JsonConverter that handles both String and DateTime types for nullable DateTime fields.
/// This makes deserialization more robust against APIs that might return either format.
class NullableDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is String) {
      // Handle empty strings gracefully
      if (json.isEmpty) return null;
      return DateTime.tryParse(json);
    }
    // Handle integer timestamps (milliseconds since epoch)
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true);
    }
    // Return null or throw an exception if the type is unexpected
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    // Convert to UTC to ensure consistency across timezones
    return object?.toUtc().toIso8601String();
  }
}
