// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whtr.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WhtrProfileImpl _$$WhtrProfileImplFromJson(Map<String, dynamic> json) =>
    _$WhtrProfileImpl(
      ratio: (json['ratio'] as num).toDouble(),
      gradation: json['gradation'] as String,
    );

Map<String, dynamic> _$$WhtrProfileImplToJson(_$WhtrProfileImpl instance) =>
    <String, dynamic>{
      'ratio': instance.ratio,
      'gradation': instance.gradation,
    };

_$WhtrProfilesImpl _$$WhtrProfilesImplFromJson(Map<String, dynamic> json) =>
    _$WhtrProfilesImpl(
      start: WhtrProfile.fromJson(json['start'] as Map<String, dynamic>),
      finish: WhtrProfile.fromJson(json['finish'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WhtrProfilesImplToJson(_$WhtrProfilesImpl instance) =>
    <String, dynamic>{
      'start': instance.start,
      'finish': instance.finish,
    };
