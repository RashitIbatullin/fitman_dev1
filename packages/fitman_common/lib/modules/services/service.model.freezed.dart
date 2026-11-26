// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Service _$ServiceFromJson(Map<String, dynamic> json) {
  return _Service.fromJson(json);
}

/// @nodoc
mixin _$Service {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get serviceTypeId => throw _privateConstructorUsedError;
  String get serviceTypeCode => throw _privateConstructorUsedError;
  String get serviceTypeTitle => throw _privateConstructorUsedError;
  double? get basePrice => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  int? get durationDays => throw _privateConstructorUsedError;
  int get usageLimitMode => throw _privateConstructorUsedError;
  int? get maxUses => throw _privateConstructorUsedError;
  int? get quotaPeriod => throw _privateConstructorUsedError;
  int? get quotaLimit => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  bool get activationRequired => throw _privateConstructorUsedError;
  bool get allowStacking => throw _privateConstructorUsedError;
  bool get grantsAccess => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Service to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceCopyWith<Service> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceCopyWith<$Res> {
  factory $ServiceCopyWith(Service value, $Res Function(Service) then) =
      _$ServiceCopyWithImpl<$Res, Service>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    String serviceTypeId,
    String serviceTypeCode,
    String serviceTypeTitle,
    double? basePrice,
    String currency,
    int? durationDays,
    int usageLimitMode,
    int? maxUses,
    int? quotaPeriod,
    int? quotaLimit,
    int? durationMinutes,
    bool activationRequired,
    bool allowStacking,
    bool grantsAccess,
    bool isActive,
  });
}

/// @nodoc
class _$ServiceCopyWithImpl<$Res, $Val extends Service>
    implements $ServiceCopyWith<$Res> {
  _$ServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? serviceTypeId = null,
    Object? serviceTypeCode = null,
    Object? serviceTypeTitle = null,
    Object? basePrice = freezed,
    Object? currency = null,
    Object? durationDays = freezed,
    Object? usageLimitMode = null,
    Object? maxUses = freezed,
    Object? quotaPeriod = freezed,
    Object? quotaLimit = freezed,
    Object? durationMinutes = freezed,
    Object? activationRequired = null,
    Object? allowStacking = null,
    Object? grantsAccess = null,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceTypeId: null == serviceTypeId
                ? _value.serviceTypeId
                : serviceTypeId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceTypeCode: null == serviceTypeCode
                ? _value.serviceTypeCode
                : serviceTypeCode // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceTypeTitle: null == serviceTypeTitle
                ? _value.serviceTypeTitle
                : serviceTypeTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            basePrice: freezed == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            durationDays: freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            usageLimitMode: null == usageLimitMode
                ? _value.usageLimitMode
                : usageLimitMode // ignore: cast_nullable_to_non_nullable
                      as int,
            maxUses: freezed == maxUses
                ? _value.maxUses
                : maxUses // ignore: cast_nullable_to_non_nullable
                      as int?,
            quotaPeriod: freezed == quotaPeriod
                ? _value.quotaPeriod
                : quotaPeriod // ignore: cast_nullable_to_non_nullable
                      as int?,
            quotaLimit: freezed == quotaLimit
                ? _value.quotaLimit
                : quotaLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            activationRequired: null == activationRequired
                ? _value.activationRequired
                : activationRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowStacking: null == allowStacking
                ? _value.allowStacking
                : allowStacking // ignore: cast_nullable_to_non_nullable
                      as bool,
            grantsAccess: null == grantsAccess
                ? _value.grantsAccess
                : grantsAccess // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceImplCopyWith<$Res> implements $ServiceCopyWith<$Res> {
  factory _$$ServiceImplCopyWith(
    _$ServiceImpl value,
    $Res Function(_$ServiceImpl) then,
  ) = __$$ServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    String? description,
    String serviceTypeId,
    String serviceTypeCode,
    String serviceTypeTitle,
    double? basePrice,
    String currency,
    int? durationDays,
    int usageLimitMode,
    int? maxUses,
    int? quotaPeriod,
    int? quotaLimit,
    int? durationMinutes,
    bool activationRequired,
    bool allowStacking,
    bool grantsAccess,
    bool isActive,
  });
}

/// @nodoc
class __$$ServiceImplCopyWithImpl<$Res>
    extends _$ServiceCopyWithImpl<$Res, _$ServiceImpl>
    implements _$$ServiceImplCopyWith<$Res> {
  __$$ServiceImplCopyWithImpl(
    _$ServiceImpl _value,
    $Res Function(_$ServiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? serviceTypeId = null,
    Object? serviceTypeCode = null,
    Object? serviceTypeTitle = null,
    Object? basePrice = freezed,
    Object? currency = null,
    Object? durationDays = freezed,
    Object? usageLimitMode = null,
    Object? maxUses = freezed,
    Object? quotaPeriod = freezed,
    Object? quotaLimit = freezed,
    Object? durationMinutes = freezed,
    Object? activationRequired = null,
    Object? allowStacking = null,
    Object? grantsAccess = null,
    Object? isActive = null,
  }) {
    return _then(
      _$ServiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceTypeId: null == serviceTypeId
            ? _value.serviceTypeId
            : serviceTypeId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceTypeCode: null == serviceTypeCode
            ? _value.serviceTypeCode
            : serviceTypeCode // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceTypeTitle: null == serviceTypeTitle
            ? _value.serviceTypeTitle
            : serviceTypeTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        basePrice: freezed == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        durationDays: freezed == durationDays
            ? _value.durationDays
            : durationDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        usageLimitMode: null == usageLimitMode
            ? _value.usageLimitMode
            : usageLimitMode // ignore: cast_nullable_to_non_nullable
                  as int,
        maxUses: freezed == maxUses
            ? _value.maxUses
            : maxUses // ignore: cast_nullable_to_non_nullable
                  as int?,
        quotaPeriod: freezed == quotaPeriod
            ? _value.quotaPeriod
            : quotaPeriod // ignore: cast_nullable_to_non_nullable
                  as int?,
        quotaLimit: freezed == quotaLimit
            ? _value.quotaLimit
            : quotaLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        activationRequired: null == activationRequired
            ? _value.activationRequired
            : activationRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowStacking: null == allowStacking
            ? _value.allowStacking
            : allowStacking // ignore: cast_nullable_to_non_nullable
                  as bool,
        grantsAccess: null == grantsAccess
            ? _value.grantsAccess
            : grantsAccess // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceImpl implements _Service {
  const _$ServiceImpl({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.serviceTypeId,
    required this.serviceTypeCode,
    required this.serviceTypeTitle,
    this.basePrice,
    required this.currency,
    this.durationDays,
    required this.usageLimitMode,
    this.maxUses,
    this.quotaPeriod,
    this.quotaLimit,
    this.durationMinutes,
    required this.activationRequired,
    required this.allowStacking,
    required this.grantsAccess,
    required this.isActive,
  });

  factory _$ServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String serviceTypeId;
  @override
  final String serviceTypeCode;
  @override
  final String serviceTypeTitle;
  @override
  final double? basePrice;
  @override
  final String currency;
  @override
  final int? durationDays;
  @override
  final int usageLimitMode;
  @override
  final int? maxUses;
  @override
  final int? quotaPeriod;
  @override
  final int? quotaLimit;
  @override
  final int? durationMinutes;
  @override
  final bool activationRequired;
  @override
  final bool allowStacking;
  @override
  final bool grantsAccess;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'Service(id: $id, code: $code, name: $name, description: $description, serviceTypeId: $serviceTypeId, serviceTypeCode: $serviceTypeCode, serviceTypeTitle: $serviceTypeTitle, basePrice: $basePrice, currency: $currency, durationDays: $durationDays, usageLimitMode: $usageLimitMode, maxUses: $maxUses, quotaPeriod: $quotaPeriod, quotaLimit: $quotaLimit, durationMinutes: $durationMinutes, activationRequired: $activationRequired, allowStacking: $allowStacking, grantsAccess: $grantsAccess, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.serviceTypeId, serviceTypeId) ||
                other.serviceTypeId == serviceTypeId) &&
            (identical(other.serviceTypeCode, serviceTypeCode) ||
                other.serviceTypeCode == serviceTypeCode) &&
            (identical(other.serviceTypeTitle, serviceTypeTitle) ||
                other.serviceTypeTitle == serviceTypeTitle) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.usageLimitMode, usageLimitMode) ||
                other.usageLimitMode == usageLimitMode) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.quotaPeriod, quotaPeriod) ||
                other.quotaPeriod == quotaPeriod) &&
            (identical(other.quotaLimit, quotaLimit) ||
                other.quotaLimit == quotaLimit) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.activationRequired, activationRequired) ||
                other.activationRequired == activationRequired) &&
            (identical(other.allowStacking, allowStacking) ||
                other.allowStacking == allowStacking) &&
            (identical(other.grantsAccess, grantsAccess) ||
                other.grantsAccess == grantsAccess) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    code,
    name,
    description,
    serviceTypeId,
    serviceTypeCode,
    serviceTypeTitle,
    basePrice,
    currency,
    durationDays,
    usageLimitMode,
    maxUses,
    quotaPeriod,
    quotaLimit,
    durationMinutes,
    activationRequired,
    allowStacking,
    grantsAccess,
    isActive,
  ]);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      __$$ServiceImplCopyWithImpl<_$ServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceImplToJson(this);
  }
}

abstract class _Service implements Service {
  const factory _Service({
    required final String id,
    required final String code,
    required final String name,
    final String? description,
    required final String serviceTypeId,
    required final String serviceTypeCode,
    required final String serviceTypeTitle,
    final double? basePrice,
    required final String currency,
    final int? durationDays,
    required final int usageLimitMode,
    final int? maxUses,
    final int? quotaPeriod,
    final int? quotaLimit,
    final int? durationMinutes,
    required final bool activationRequired,
    required final bool allowStacking,
    required final bool grantsAccess,
    required final bool isActive,
  }) = _$ServiceImpl;

  factory _Service.fromJson(Map<String, dynamic> json) = _$ServiceImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get serviceTypeId;
  @override
  String get serviceTypeCode;
  @override
  String get serviceTypeTitle;
  @override
  double? get basePrice;
  @override
  String get currency;
  @override
  int? get durationDays;
  @override
  int get usageLimitMode;
  @override
  int? get maxUses;
  @override
  int? get quotaPeriod;
  @override
  int? get quotaLimit;
  @override
  int? get durationMinutes;
  @override
  bool get activationRequired;
  @override
  bool get allowStacking;
  @override
  bool get grantsAccess;
  @override
  bool get isActive;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
