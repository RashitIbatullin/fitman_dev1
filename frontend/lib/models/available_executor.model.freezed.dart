// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'available_executor.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AvailableExecutorsResponse _$AvailableExecutorsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _AvailableExecutorsResponse.fromJson(json);
}

/// @nodoc
mixin _$AvailableExecutorsResponse {
  List<Executor> get users => throw _privateConstructorUsedError;
  List<Executor> get staff => throw _privateConstructorUsedError;

  /// Serializes this AvailableExecutorsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvailableExecutorsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailableExecutorsResponseCopyWith<AvailableExecutorsResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailableExecutorsResponseCopyWith<$Res> {
  factory $AvailableExecutorsResponseCopyWith(
    AvailableExecutorsResponse value,
    $Res Function(AvailableExecutorsResponse) then,
  ) =
      _$AvailableExecutorsResponseCopyWithImpl<
        $Res,
        AvailableExecutorsResponse
      >;
  @useResult
  $Res call({List<Executor> users, List<Executor> staff});
}

/// @nodoc
class _$AvailableExecutorsResponseCopyWithImpl<
  $Res,
  $Val extends AvailableExecutorsResponse
>
    implements $AvailableExecutorsResponseCopyWith<$Res> {
  _$AvailableExecutorsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailableExecutorsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? users = null, Object? staff = null}) {
    return _then(
      _value.copyWith(
            users: null == users
                ? _value.users
                : users // ignore: cast_nullable_to_non_nullable
                      as List<Executor>,
            staff: null == staff
                ? _value.staff
                : staff // ignore: cast_nullable_to_non_nullable
                      as List<Executor>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AvailableExecutorsResponseImplCopyWith<$Res>
    implements $AvailableExecutorsResponseCopyWith<$Res> {
  factory _$$AvailableExecutorsResponseImplCopyWith(
    _$AvailableExecutorsResponseImpl value,
    $Res Function(_$AvailableExecutorsResponseImpl) then,
  ) = __$$AvailableExecutorsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Executor> users, List<Executor> staff});
}

/// @nodoc
class __$$AvailableExecutorsResponseImplCopyWithImpl<$Res>
    extends
        _$AvailableExecutorsResponseCopyWithImpl<
          $Res,
          _$AvailableExecutorsResponseImpl
        >
    implements _$$AvailableExecutorsResponseImplCopyWith<$Res> {
  __$$AvailableExecutorsResponseImplCopyWithImpl(
    _$AvailableExecutorsResponseImpl _value,
    $Res Function(_$AvailableExecutorsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AvailableExecutorsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? users = null, Object? staff = null}) {
    return _then(
      _$AvailableExecutorsResponseImpl(
        users: null == users
            ? _value._users
            : users // ignore: cast_nullable_to_non_nullable
                  as List<Executor>,
        staff: null == staff
            ? _value._staff
            : staff // ignore: cast_nullable_to_non_nullable
                  as List<Executor>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailableExecutorsResponseImpl implements _AvailableExecutorsResponse {
  const _$AvailableExecutorsResponseImpl({
    required final List<Executor> users,
    required final List<Executor> staff,
  }) : _users = users,
       _staff = staff;

  factory _$AvailableExecutorsResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$AvailableExecutorsResponseImplFromJson(json);

  final List<Executor> _users;
  @override
  List<Executor> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

  final List<Executor> _staff;
  @override
  List<Executor> get staff {
    if (_staff is EqualUnmodifiableListView) return _staff;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_staff);
  }

  @override
  String toString() {
    return 'AvailableExecutorsResponse(users: $users, staff: $staff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailableExecutorsResponseImpl &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            const DeepCollectionEquality().equals(other._staff, _staff));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_users),
    const DeepCollectionEquality().hash(_staff),
  );

  /// Create a copy of AvailableExecutorsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailableExecutorsResponseImplCopyWith<_$AvailableExecutorsResponseImpl>
  get copyWith =>
      __$$AvailableExecutorsResponseImplCopyWithImpl<
        _$AvailableExecutorsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailableExecutorsResponseImplToJson(this);
  }
}

abstract class _AvailableExecutorsResponse
    implements AvailableExecutorsResponse {
  const factory _AvailableExecutorsResponse({
    required final List<Executor> users,
    required final List<Executor> staff,
  }) = _$AvailableExecutorsResponseImpl;

  factory _AvailableExecutorsResponse.fromJson(Map<String, dynamic> json) =
      _$AvailableExecutorsResponseImpl.fromJson;

  @override
  List<Executor> get users;
  @override
  List<Executor> get staff;

  /// Create a copy of AvailableExecutorsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailableExecutorsResponseImplCopyWith<_$AvailableExecutorsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Executor _$ExecutorFromJson(Map<String, dynamic> json) {
  return _Executor.fromJson(json);
}

/// @nodoc
mixin _$Executor {
  String get id => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;

  /// Serializes this Executor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Executor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExecutorCopyWith<Executor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExecutorCopyWith<$Res> {
  factory $ExecutorCopyWith(Executor value, $Res Function(Executor) then) =
      _$ExecutorCopyWithImpl<$Res, Executor>;
  @useResult
  $Res call({String id, String? firstName, String? lastName});
}

/// @nodoc
class _$ExecutorCopyWithImpl<$Res, $Val extends Executor>
    implements $ExecutorCopyWith<$Res> {
  _$ExecutorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Executor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExecutorImplCopyWith<$Res>
    implements $ExecutorCopyWith<$Res> {
  factory _$$ExecutorImplCopyWith(
    _$ExecutorImpl value,
    $Res Function(_$ExecutorImpl) then,
  ) = __$$ExecutorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? firstName, String? lastName});
}

/// @nodoc
class __$$ExecutorImplCopyWithImpl<$Res>
    extends _$ExecutorCopyWithImpl<$Res, _$ExecutorImpl>
    implements _$$ExecutorImplCopyWith<$Res> {
  __$$ExecutorImplCopyWithImpl(
    _$ExecutorImpl _value,
    $Res Function(_$ExecutorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Executor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
  }) {
    return _then(
      _$ExecutorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExecutorImpl implements _Executor {
  const _$ExecutorImpl({required this.id, this.firstName, this.lastName});

  factory _$ExecutorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExecutorImplFromJson(json);

  @override
  final String id;
  @override
  final String? firstName;
  @override
  final String? lastName;

  @override
  String toString() {
    return 'Executor(id: $id, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExecutorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName);

  /// Create a copy of Executor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExecutorImplCopyWith<_$ExecutorImpl> get copyWith =>
      __$$ExecutorImplCopyWithImpl<_$ExecutorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExecutorImplToJson(this);
  }
}

abstract class _Executor implements Executor {
  const factory _Executor({
    required final String id,
    final String? firstName,
    final String? lastName,
  }) = _$ExecutorImpl;

  factory _Executor.fromJson(Map<String, dynamic> json) =
      _$ExecutorImpl.fromJson;

  @override
  String get id;
  @override
  String? get firstName;
  @override
  String? get lastName;

  /// Create a copy of Executor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExecutorImplCopyWith<_$ExecutorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
