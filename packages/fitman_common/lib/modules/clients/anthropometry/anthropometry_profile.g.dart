// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anthropometry_profile.dart';

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

_$MetabolicProfileImpl _$$MetabolicProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$MetabolicProfileImpl(
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
    );

Map<String, dynamic> _$$MetabolicProfileImplToJson(
        _$MetabolicProfileImpl instance) =>
    <String, dynamic>{
      'bmr': instance.bmr,
      'tdee': instance.tdee,
    };
