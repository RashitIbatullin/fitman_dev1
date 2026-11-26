import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.model.freezed.dart';
part 'appointment.model.g.dart';

/// Статусы записи на услугу.
abstract final class AppointmentStatus {
  static const int scheduled = 0;
  static const int completed = 1;
  static const int skipped = 2;
  static const int rescheduled = 3;
  static const int cancelled = 4;
  static const int refused = 5;
}

/// Сторона пропуска: от неё зависит, списывается ли сеанс.
abstract final class AppointmentSkipParty {
  static const int client = 1;
  static const int employee = 2;
  static const int administration = 3;
}

/// Запись клиента на услугу с исполнителем (массаж, СПА, анализы).
///
/// Это не занятие (`Lesson`): у записи нет плана тренировки и упражнений,
/// и по ней не строится сетка слотов.
@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String clientId,
    String? clientName,
    required String serviceId,
    required String serviceName,
    String? serviceDescription,
    String? executorId,
    String? executorName,
    required DateTime startAt,
    int? durationMinutes,
    required int status,
    String? note,
    int? skipParty,
    int? skipReason,
    String? purchaseId,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
}
