// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_catalogs.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GoalTraining _$GoalTrainingFromJson(Map<String, dynamic> json) {
  return _GoalTraining.fromJson(json);
}

/// @nodoc
mixin _$GoalTraining {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this GoalTraining to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalTraining
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalTrainingCopyWith<GoalTraining> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalTrainingCopyWith<$Res> {
  factory $GoalTrainingCopyWith(
    GoalTraining value,
    $Res Function(GoalTraining) then,
  ) = _$GoalTrainingCopyWithImpl<$Res, GoalTraining>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$GoalTrainingCopyWithImpl<$Res, $Val extends GoalTraining>
    implements $GoalTrainingCopyWith<$Res> {
  _$GoalTrainingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalTraining
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoalTrainingImplCopyWith<$Res>
    implements $GoalTrainingCopyWith<$Res> {
  factory _$$GoalTrainingImplCopyWith(
    _$GoalTrainingImpl value,
    $Res Function(_$GoalTrainingImpl) then,
  ) = __$$GoalTrainingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$GoalTrainingImplCopyWithImpl<$Res>
    extends _$GoalTrainingCopyWithImpl<$Res, _$GoalTrainingImpl>
    implements _$$GoalTrainingImplCopyWith<$Res> {
  __$$GoalTrainingImplCopyWithImpl(
    _$GoalTrainingImpl _value,
    $Res Function(_$GoalTrainingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoalTraining
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$GoalTrainingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalTrainingImpl implements _GoalTraining {
  const _$GoalTrainingImpl({required this.id, required this.name});

  factory _$GoalTrainingImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalTrainingImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'GoalTraining(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalTrainingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of GoalTraining
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalTrainingImplCopyWith<_$GoalTrainingImpl> get copyWith =>
      __$$GoalTrainingImplCopyWithImpl<_$GoalTrainingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalTrainingImplToJson(this);
  }
}

abstract class _GoalTraining implements GoalTraining {
  const factory _GoalTraining({
    required final String id,
    required final String name,
  }) = _$GoalTrainingImpl;

  factory _GoalTraining.fromJson(Map<String, dynamic> json) =
      _$GoalTrainingImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of GoalTraining
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalTrainingImplCopyWith<_$GoalTrainingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LevelTraining _$LevelTrainingFromJson(Map<String, dynamic> json) {
  return _LevelTraining.fromJson(json);
}

/// @nodoc
mixin _$LevelTraining {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this LevelTraining to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelTraining
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelTrainingCopyWith<LevelTraining> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelTrainingCopyWith<$Res> {
  factory $LevelTrainingCopyWith(
    LevelTraining value,
    $Res Function(LevelTraining) then,
  ) = _$LevelTrainingCopyWithImpl<$Res, LevelTraining>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$LevelTrainingCopyWithImpl<$Res, $Val extends LevelTraining>
    implements $LevelTrainingCopyWith<$Res> {
  _$LevelTrainingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelTraining
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LevelTrainingImplCopyWith<$Res>
    implements $LevelTrainingCopyWith<$Res> {
  factory _$$LevelTrainingImplCopyWith(
    _$LevelTrainingImpl value,
    $Res Function(_$LevelTrainingImpl) then,
  ) = __$$LevelTrainingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$LevelTrainingImplCopyWithImpl<$Res>
    extends _$LevelTrainingCopyWithImpl<$Res, _$LevelTrainingImpl>
    implements _$$LevelTrainingImplCopyWith<$Res> {
  __$$LevelTrainingImplCopyWithImpl(
    _$LevelTrainingImpl _value,
    $Res Function(_$LevelTrainingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LevelTraining
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$LevelTrainingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelTrainingImpl implements _LevelTraining {
  const _$LevelTrainingImpl({required this.id, required this.name});

  factory _$LevelTrainingImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelTrainingImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'LevelTraining(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelTrainingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of LevelTraining
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelTrainingImplCopyWith<_$LevelTrainingImpl> get copyWith =>
      __$$LevelTrainingImplCopyWithImpl<_$LevelTrainingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelTrainingImplToJson(this);
  }
}

abstract class _LevelTraining implements LevelTraining {
  const factory _LevelTraining({
    required final String id,
    required final String name,
  }) = _$LevelTrainingImpl;

  factory _LevelTraining.fromJson(Map<String, dynamic> json) =
      _$LevelTrainingImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of LevelTraining
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelTrainingImplCopyWith<_$LevelTrainingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
