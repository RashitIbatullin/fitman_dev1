import 'package:fitman_common/fitman_common.dart';

import 'base_api.dart';

/// Записи на услуги с исполнителем (массаж, СПА, косметология).
class AppointmentsApiService extends BaseApiService {
  AppointmentsApiService({super.client});

  Future<List<Appointment>> getAppointments({
    DateTime? from,
    DateTime? to,
    String? executorId,
    int? status,
  }) async {
    final query = <String, String>{};
    if (from != null) query['from'] = from.toIso8601String();
    if (to != null) query['to'] = to.toIso8601String();
    if (executorId != null) query['executorId'] = executorId;
    if (status != null) query['status'] = status.toString();

    final data = await get(
      '/api/appointments',
      queryParams: query.isEmpty ? null : query,
    );
    final items = data as List<dynamic>;
    return items
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> complete(String appointmentId) async {
    await post('/api/appointments/$appointmentId/complete', body: const {});
  }

  Future<void> skip(
    String appointmentId, {
    required int party,
    required int reason,
    String? note,
  }) async {
    await post(
      '/api/appointments/$appointmentId/skip',
      body: {
        'party': party,
        'reason': reason,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
  }
}
