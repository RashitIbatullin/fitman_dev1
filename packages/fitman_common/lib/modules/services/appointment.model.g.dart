// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentImpl _$$AppointmentImplFromJson(Map<String, dynamic> json) =>
    _$AppointmentImpl(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String?,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      serviceDescription: json['service_description'] as String?,
      executorId: json['executor_id'] as String?,
      executorName: json['executor_name'] as String?,
      startAt: DateTime.parse(json['start_at'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      status: (json['status'] as num).toInt(),
      note: json['note'] as String?,
      skipParty: (json['skip_party'] as num?)?.toInt(),
      skipReason: (json['skip_reason'] as num?)?.toInt(),
      purchaseId: json['purchase_id'] as String?,
    );

Map<String, dynamic> _$$AppointmentImplToJson(_$AppointmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'client_name': instance.clientName,
      'service_id': instance.serviceId,
      'service_name': instance.serviceName,
      'service_description': instance.serviceDescription,
      'executor_id': instance.executorId,
      'executor_name': instance.executorName,
      'start_at': instance.startAt.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
      'status': instance.status,
      'note': instance.note,
      'skip_party': instance.skipParty,
      'skip_reason': instance.skipReason,
      'purchase_id': instance.purchaseId,
    };
