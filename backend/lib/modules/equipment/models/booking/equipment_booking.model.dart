import 'package:fitman_backend/modules/equipment/models/booking/booking_status.enum.dart';

class EquipmentBooking {
  EquipmentBooking({
    required this.id,
    required this.equipmentItemId,
    required this.bookedById,
    required this.startTime,
    required this.endTime,
    this.lessonId,
    this.trainingGroupId,
    required this.purpose,
    required this.status,
    this.notes,
  });

  final String id;
  final String equipmentItemId;
  final String bookedById;

  // Время бронирования
  final DateTime startTime;
  final DateTime endTime;

  // Контекст
  final String? lessonId;
  final String? trainingGroupId;
  final String purpose;

  // Статус
  final BookingStatus status;

  // Дополнительно
  final String? notes;
}
