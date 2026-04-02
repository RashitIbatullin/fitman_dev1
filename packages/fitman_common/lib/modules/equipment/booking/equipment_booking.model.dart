import 'package:freezed_annotation/freezed_annotation.dart';
import 'booking_status.enum.dart';

part 'equipment_booking.model.freezed.dart';
part 'equipment_booking.model.g.dart';

@freezed
class EquipmentBooking with _$EquipmentBooking {
  const factory EquipmentBooking({
    required String id,
    required String equipmentItemId,
    required String bookedById,
    required DateTime startTime,
    required DateTime endTime,
    String? lessonId,
    String? trainingGroupId,
    required String purpose,
    required BookingStatus status,
    String? notes,
  }) = _EquipmentBooking;

  factory EquipmentBooking.fromJson(Map<String, dynamic> json) =>
      _$EquipmentBookingFromJson(json);
}
