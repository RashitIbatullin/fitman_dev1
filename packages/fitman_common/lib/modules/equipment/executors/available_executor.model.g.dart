// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_executor.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvailableExecutorsResponseImpl _$$AvailableExecutorsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AvailableExecutorsResponseImpl(
  users: (json['users'] as List<dynamic>)
      .map((e) => Executor.fromJson(e as Map<String, dynamic>))
      .toList(),
  staff: (json['staff'] as List<dynamic>)
      .map((e) => Executor.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$AvailableExecutorsResponseImplToJson(
  _$AvailableExecutorsResponseImpl instance,
) => <String, dynamic>{'users': instance.users, 'staff': instance.staff};

_$ExecutorImpl _$$ExecutorImplFromJson(Map<String, dynamic> json) =>
    _$ExecutorImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$$ExecutorImplToJson(_$ExecutorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };
