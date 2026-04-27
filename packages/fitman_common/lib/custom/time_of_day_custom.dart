import 'package:equatable/equatable.dart';

// Helper class for TimeOfDay as it's not directly JSON serializable
class TimeOfDayCustom extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDayCustom({required this.hour, required this.minute});

  factory TimeOfDayCustom.fromJson(String time) {
    final parts = time.split(':');
    return TimeOfDayCustom(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  factory TimeOfDayCustom.parse(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDayCustom(
      hour: int.parse(parts[0]), minute: int.parse(parts[1]),
    );
  }

  String toJson() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';

  bool isBefore(TimeOfDayCustom other) {
    if (hour < other.hour) {
      return true;
    }
    if (hour == other.hour && minute < other.minute) {
      return true;
    }
    return false;
  }

  bool isAfter(TimeOfDayCustom other) {
    if (hour > other.hour) {
      return true;
    }
    if (hour == other.hour && minute > other.minute) {
      return true;
    }
    return false;
  }

  @override
  List<Object?> get props => [hour, minute];
}

