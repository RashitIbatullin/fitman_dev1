// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_condition.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupCondition _$GroupConditionFromJson(Map<String, dynamic> json) =>
    GroupCondition(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$GroupConditionToJson(GroupCondition instance) =>
    <String, dynamic>{
      'field': instance.field,
      'operator': instance.operator,
      'value': instance.value,
    };
