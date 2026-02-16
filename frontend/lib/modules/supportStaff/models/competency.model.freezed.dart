// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competency.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Competency _$CompetencyFromJson(Map<String, dynamic> json) {
  return _Competency.fromJson(json);
}

/// @nodoc
mixin _$Competency {
  String get id => throw _privateConstructorUsedError;
  String get staffId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  String? get certificateUrl => throw _privateConstructorUsedError;
  DateTime? get verifiedAt => throw _privateConstructorUsedError;
  String? get verifiedBy => throw _privateConstructorUsedError;

  /// Serializes this Competency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompetencyCopyWith<Competency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetencyCopyWith<$Res> {
  factory $CompetencyCopyWith(
    Competency value,
    $Res Function(Competency) then,
  ) = _$CompetencyCopyWithImpl<$Res, Competency>;
  @useResult
  $Res call({
    String id,
    String staffId,
    String name,
    int level,
    String? certificateUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
  });
}

/// @nodoc
class _$CompetencyCopyWithImpl<$Res, $Val extends Competency>
    implements $CompetencyCopyWith<$Res> {
  _$CompetencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffId = null,
    Object? name = null,
    Object? level = null,
    Object? certificateUrl = freezed,
    Object? verifiedAt = freezed,
    Object? verifiedBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            staffId: null == staffId
                ? _value.staffId
                : staffId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            certificateUrl: freezed == certificateUrl
                ? _value.certificateUrl
                : certificateUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            verifiedAt: freezed == verifiedAt
                ? _value.verifiedAt
                : verifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            verifiedBy: freezed == verifiedBy
                ? _value.verifiedBy
                : verifiedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompetencyImplCopyWith<$Res>
    implements $CompetencyCopyWith<$Res> {
  factory _$$CompetencyImplCopyWith(
    _$CompetencyImpl value,
    $Res Function(_$CompetencyImpl) then,
  ) = __$$CompetencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String staffId,
    String name,
    int level,
    String? certificateUrl,
    DateTime? verifiedAt,
    String? verifiedBy,
  });
}

/// @nodoc
class __$$CompetencyImplCopyWithImpl<$Res>
    extends _$CompetencyCopyWithImpl<$Res, _$CompetencyImpl>
    implements _$$CompetencyImplCopyWith<$Res> {
  __$$CompetencyImplCopyWithImpl(
    _$CompetencyImpl _value,
    $Res Function(_$CompetencyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffId = null,
    Object? name = null,
    Object? level = null,
    Object? certificateUrl = freezed,
    Object? verifiedAt = freezed,
    Object? verifiedBy = freezed,
  }) {
    return _then(
      _$CompetencyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        staffId: null == staffId
            ? _value.staffId
            : staffId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        certificateUrl: freezed == certificateUrl
            ? _value.certificateUrl
            : certificateUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        verifiedAt: freezed == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        verifiedBy: freezed == verifiedBy
            ? _value.verifiedBy
            : verifiedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompetencyImpl implements _Competency {
  const _$CompetencyImpl({
    required this.id,
    required this.staffId,
    required this.name,
    required this.level,
    this.certificateUrl,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory _$CompetencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetencyImplFromJson(json);

  @override
  final String id;
  @override
  final String staffId;
  @override
  final String name;
  @override
  final int level;
  @override
  final String? certificateUrl;
  @override
  final DateTime? verifiedAt;
  @override
  final String? verifiedBy;

  @override
  String toString() {
    return 'Competency(id: $id, staffId: $staffId, name: $name, level: $level, certificateUrl: $certificateUrl, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetencyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.certificateUrl, certificateUrl) ||
                other.certificateUrl == certificateUrl) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    staffId,
    name,
    level,
    certificateUrl,
    verifiedAt,
    verifiedBy,
  );

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetencyImplCopyWith<_$CompetencyImpl> get copyWith =>
      __$$CompetencyImplCopyWithImpl<_$CompetencyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetencyImplToJson(this);
  }
}

abstract class _Competency implements Competency {
  const factory _Competency({
    required final String id,
    required final String staffId,
    required final String name,
    required final int level,
    final String? certificateUrl,
    final DateTime? verifiedAt,
    final String? verifiedBy,
  }) = _$CompetencyImpl;

  factory _Competency.fromJson(Map<String, dynamic> json) =
      _$CompetencyImpl.fromJson;

  @override
  String get id;
  @override
  String get staffId;
  @override
  String get name;
  @override
  int get level;
  @override
  String? get certificateUrl;
  @override
  DateTime? get verifiedAt;
  @override
  String? get verifiedBy;

  /// Create a copy of Competency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompetencyImplCopyWith<_$CompetencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
