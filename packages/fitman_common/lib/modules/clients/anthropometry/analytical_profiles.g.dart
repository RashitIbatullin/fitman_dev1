// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytical_profiles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WhtrProfileImpl _$$WhtrProfileImplFromJson(Map<String, dynamic> json) =>
    _$WhtrProfileImpl(
      ratio: (json['ratio'] as num).toDouble(),
      gradation: json['gradation'] as String,
    );

Map<String, dynamic> _$$WhtrProfileImplToJson(_$WhtrProfileImpl instance) =>
    <String, dynamic>{'ratio': instance.ratio, 'gradation': instance.gradation};

_$MetabolicProfileImpl _$$MetabolicProfileImplFromJson(
  Map<String, dynamic> json,
) => _$MetabolicProfileImpl(
  bmr: (json['bmr'] as num).toDouble(),
  tdee: (json['tdee'] as num).toDouble(),
);

Map<String, dynamic> _$$MetabolicProfileImplToJson(
  _$MetabolicProfileImpl instance,
) => <String, dynamic>{'bmr': instance.bmr, 'tdee': instance.tdee};
