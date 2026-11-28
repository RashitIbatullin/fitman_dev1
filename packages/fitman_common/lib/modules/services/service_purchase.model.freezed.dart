// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_purchase.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServicePurchase _$ServicePurchaseFromJson(Map<String, dynamic> json) {
  return _ServicePurchase.fromJson(json);
}

/// @nodoc
mixin _$ServicePurchase {
  String get id => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String? get clientName => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  String get serviceName => throw _privateConstructorUsedError;
  String? get serviceCode => throw _privateConstructorUsedError;
  String? get serviceTypeCode => throw _privateConstructorUsedError;
  String? get serviceTypeTitle => throw _privateConstructorUsedError;
  String? get executorSpecializationCode => throw _privateConstructorUsedError;
  String? get executorSpecializationTitle => throw _privateConstructorUsedError;
  double? get purchasePrice => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;
  double? get finalPrice => throw _privateConstructorUsedError;
  int get paymentStatus => throw _privateConstructorUsedError;
  int? get paymentSource => throw _privateConstructorUsedError;
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  DateTime? get activationDate => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  DateTime? get actualExpiryDate => throw _privateConstructorUsedError;
  int? get totalUses => throw _privateConstructorUsedError;
  int get usedUses => throw _privateConstructorUsedError;
  int? get remainingUses => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  int? get quotaUsed => throw _privateConstructorUsedError;
  int? get quotaLimit => throw _privateConstructorUsedError;
  int? get quotaPeriod => throw _privateConstructorUsedError;
  DateTime? get quotaPeriodStart => throw _privateConstructorUsedError;
  DateTime? get quotaPeriodEnd => throw _privateConstructorUsedError;
  int get usageLimitMode => throw _privateConstructorUsedError;

  /// Serializes this ServicePurchase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServicePurchase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServicePurchaseCopyWith<ServicePurchase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServicePurchaseCopyWith<$Res> {
  factory $ServicePurchaseCopyWith(
    ServicePurchase value,
    $Res Function(ServicePurchase) then,
  ) = _$ServicePurchaseCopyWithImpl<$Res, ServicePurchase>;
  @useResult
  $Res call({
    String id,
    String clientId,
    String? clientName,
    String serviceId,
    String serviceName,
    String? serviceCode,
    String? serviceTypeCode,
    String? serviceTypeTitle,
    String? executorSpecializationCode,
    String? executorSpecializationTitle,
    double? purchasePrice,
    double discountPercent,
    double discountAmount,
    double? finalPrice,
    int paymentStatus,
    int? paymentSource,
    DateTime purchaseDate,
    DateTime? activationDate,
    DateTime? expiryDate,
    DateTime? actualExpiryDate,
    int? totalUses,
    int usedUses,
    int? remainingUses,
    int status,
    int? quotaUsed,
    int? quotaLimit,
    int? quotaPeriod,
    DateTime? quotaPeriodStart,
    DateTime? quotaPeriodEnd,
    int usageLimitMode,
  });
}

/// @nodoc
class _$ServicePurchaseCopyWithImpl<$Res, $Val extends ServicePurchase>
    implements $ServicePurchaseCopyWith<$Res> {
  _$ServicePurchaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServicePurchase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? clientName = freezed,
    Object? serviceId = null,
    Object? serviceName = null,
    Object? serviceCode = freezed,
    Object? serviceTypeCode = freezed,
    Object? serviceTypeTitle = freezed,
    Object? executorSpecializationCode = freezed,
    Object? executorSpecializationTitle = freezed,
    Object? purchasePrice = freezed,
    Object? discountPercent = null,
    Object? discountAmount = null,
    Object? finalPrice = freezed,
    Object? paymentStatus = null,
    Object? paymentSource = freezed,
    Object? purchaseDate = null,
    Object? activationDate = freezed,
    Object? expiryDate = freezed,
    Object? actualExpiryDate = freezed,
    Object? totalUses = freezed,
    Object? usedUses = null,
    Object? remainingUses = freezed,
    Object? status = null,
    Object? quotaUsed = freezed,
    Object? quotaLimit = freezed,
    Object? quotaPeriod = freezed,
    Object? quotaPeriodStart = freezed,
    Object? quotaPeriodEnd = freezed,
    Object? usageLimitMode = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            clientId: null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                      as String,
            clientName: freezed == clientName
                ? _value.clientName
                : clientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceName: null == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceCode: freezed == serviceCode
                ? _value.serviceCode
                : serviceCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceTypeCode: freezed == serviceTypeCode
                ? _value.serviceTypeCode
                : serviceTypeCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceTypeTitle: freezed == serviceTypeTitle
                ? _value.serviceTypeTitle
                : serviceTypeTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            executorSpecializationCode: freezed == executorSpecializationCode
                ? _value.executorSpecializationCode
                : executorSpecializationCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            executorSpecializationTitle: freezed == executorSpecializationTitle
                ? _value.executorSpecializationTitle
                : executorSpecializationTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchasePrice: freezed == purchasePrice
                ? _value.purchasePrice
                : purchasePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            discountPercent: null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            finalPrice: freezed == finalPrice
                ? _value.finalPrice
                : finalPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as int,
            paymentSource: freezed == paymentSource
                ? _value.paymentSource
                : paymentSource // ignore: cast_nullable_to_non_nullable
                      as int?,
            purchaseDate: null == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            activationDate: freezed == activationDate
                ? _value.activationDate
                : activationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actualExpiryDate: freezed == actualExpiryDate
                ? _value.actualExpiryDate
                : actualExpiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalUses: freezed == totalUses
                ? _value.totalUses
                : totalUses // ignore: cast_nullable_to_non_nullable
                      as int?,
            usedUses: null == usedUses
                ? _value.usedUses
                : usedUses // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingUses: freezed == remainingUses
                ? _value.remainingUses
                : remainingUses // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as int,
            quotaUsed: freezed == quotaUsed
                ? _value.quotaUsed
                : quotaUsed // ignore: cast_nullable_to_non_nullable
                      as int?,
            quotaLimit: freezed == quotaLimit
                ? _value.quotaLimit
                : quotaLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            quotaPeriod: freezed == quotaPeriod
                ? _value.quotaPeriod
                : quotaPeriod // ignore: cast_nullable_to_non_nullable
                      as int?,
            quotaPeriodStart: freezed == quotaPeriodStart
                ? _value.quotaPeriodStart
                : quotaPeriodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            quotaPeriodEnd: freezed == quotaPeriodEnd
                ? _value.quotaPeriodEnd
                : quotaPeriodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            usageLimitMode: null == usageLimitMode
                ? _value.usageLimitMode
                : usageLimitMode // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServicePurchaseImplCopyWith<$Res>
    implements $ServicePurchaseCopyWith<$Res> {
  factory _$$ServicePurchaseImplCopyWith(
    _$ServicePurchaseImpl value,
    $Res Function(_$ServicePurchaseImpl) then,
  ) = __$$ServicePurchaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String clientId,
    String? clientName,
    String serviceId,
    String serviceName,
    String? serviceCode,
    String? serviceTypeCode,
    String? serviceTypeTitle,
    String? executorSpecializationCode,
    String? executorSpecializationTitle,
    double? purchasePrice,
    double discountPercent,
    double discountAmount,
    double? finalPrice,
    int paymentStatus,
    int? paymentSource,
    DateTime purchaseDate,
    DateTime? activationDate,
    DateTime? expiryDate,
    DateTime? actualExpiryDate,
    int? totalUses,
    int usedUses,
    int? remainingUses,
    int status,
    int? quotaUsed,
    int? quotaLimit,
    int? quotaPeriod,
    DateTime? quotaPeriodStart,
    DateTime? quotaPeriodEnd,
    int usageLimitMode,
  });
}

/// @nodoc
class __$$ServicePurchaseImplCopyWithImpl<$Res>
    extends _$ServicePurchaseCopyWithImpl<$Res, _$ServicePurchaseImpl>
    implements _$$ServicePurchaseImplCopyWith<$Res> {
  __$$ServicePurchaseImplCopyWithImpl(
    _$ServicePurchaseImpl _value,
    $Res Function(_$ServicePurchaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServicePurchase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientId = null,
    Object? clientName = freezed,
    Object? serviceId = null,
    Object? serviceName = null,
    Object? serviceCode = freezed,
    Object? serviceTypeCode = freezed,
    Object? serviceTypeTitle = freezed,
    Object? executorSpecializationCode = freezed,
    Object? executorSpecializationTitle = freezed,
    Object? purchasePrice = freezed,
    Object? discountPercent = null,
    Object? discountAmount = null,
    Object? finalPrice = freezed,
    Object? paymentStatus = null,
    Object? paymentSource = freezed,
    Object? purchaseDate = null,
    Object? activationDate = freezed,
    Object? expiryDate = freezed,
    Object? actualExpiryDate = freezed,
    Object? totalUses = freezed,
    Object? usedUses = null,
    Object? remainingUses = freezed,
    Object? status = null,
    Object? quotaUsed = freezed,
    Object? quotaLimit = freezed,
    Object? quotaPeriod = freezed,
    Object? quotaPeriodStart = freezed,
    Object? quotaPeriodEnd = freezed,
    Object? usageLimitMode = null,
  }) {
    return _then(
      _$ServicePurchaseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        clientId: null == clientId
            ? _value.clientId
            : clientId // ignore: cast_nullable_to_non_nullable
                  as String,
        clientName: freezed == clientName
            ? _value.clientName
            : clientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceName: null == serviceName
            ? _value.serviceName
            : serviceName // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceCode: freezed == serviceCode
            ? _value.serviceCode
            : serviceCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceTypeCode: freezed == serviceTypeCode
            ? _value.serviceTypeCode
            : serviceTypeCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceTypeTitle: freezed == serviceTypeTitle
            ? _value.serviceTypeTitle
            : serviceTypeTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        executorSpecializationCode: freezed == executorSpecializationCode
            ? _value.executorSpecializationCode
            : executorSpecializationCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        executorSpecializationTitle: freezed == executorSpecializationTitle
            ? _value.executorSpecializationTitle
            : executorSpecializationTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchasePrice: freezed == purchasePrice
            ? _value.purchasePrice
            : purchasePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        discountPercent: null == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        finalPrice: freezed == finalPrice
            ? _value.finalPrice
            : finalPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as int,
        paymentSource: freezed == paymentSource
            ? _value.paymentSource
            : paymentSource // ignore: cast_nullable_to_non_nullable
                  as int?,
        purchaseDate: null == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        activationDate: freezed == activationDate
            ? _value.activationDate
            : activationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actualExpiryDate: freezed == actualExpiryDate
            ? _value.actualExpiryDate
            : actualExpiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalUses: freezed == totalUses
            ? _value.totalUses
            : totalUses // ignore: cast_nullable_to_non_nullable
                  as int?,
        usedUses: null == usedUses
            ? _value.usedUses
            : usedUses // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingUses: freezed == remainingUses
            ? _value.remainingUses
            : remainingUses // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int,
        quotaUsed: freezed == quotaUsed
            ? _value.quotaUsed
            : quotaUsed // ignore: cast_nullable_to_non_nullable
                  as int?,
        quotaLimit: freezed == quotaLimit
            ? _value.quotaLimit
            : quotaLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        quotaPeriod: freezed == quotaPeriod
            ? _value.quotaPeriod
            : quotaPeriod // ignore: cast_nullable_to_non_nullable
                  as int?,
        quotaPeriodStart: freezed == quotaPeriodStart
            ? _value.quotaPeriodStart
            : quotaPeriodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        quotaPeriodEnd: freezed == quotaPeriodEnd
            ? _value.quotaPeriodEnd
            : quotaPeriodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        usageLimitMode: null == usageLimitMode
            ? _value.usageLimitMode
            : usageLimitMode // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServicePurchaseImpl implements _ServicePurchase {
  const _$ServicePurchaseImpl({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.serviceId,
    required this.serviceName,
    this.serviceCode,
    this.serviceTypeCode,
    this.serviceTypeTitle,
    this.executorSpecializationCode,
    this.executorSpecializationTitle,
    this.purchasePrice,
    required this.discountPercent,
    required this.discountAmount,
    this.finalPrice,
    required this.paymentStatus,
    this.paymentSource,
    required this.purchaseDate,
    this.activationDate,
    this.expiryDate,
    this.actualExpiryDate,
    this.totalUses,
    required this.usedUses,
    this.remainingUses,
    required this.status,
    this.quotaUsed,
    this.quotaLimit,
    this.quotaPeriod,
    this.quotaPeriodStart,
    this.quotaPeriodEnd,
    required this.usageLimitMode,
  });

  factory _$ServicePurchaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServicePurchaseImplFromJson(json);

  @override
  final String id;
  @override
  final String clientId;
  @override
  final String? clientName;
  @override
  final String serviceId;
  @override
  final String serviceName;
  @override
  final String? serviceCode;
  @override
  final String? serviceTypeCode;
  @override
  final String? serviceTypeTitle;
  @override
  final String? executorSpecializationCode;
  @override
  final String? executorSpecializationTitle;
  @override
  final double? purchasePrice;
  @override
  final double discountPercent;
  @override
  final double discountAmount;
  @override
  final double? finalPrice;
  @override
  final int paymentStatus;
  @override
  final int? paymentSource;
  @override
  final DateTime purchaseDate;
  @override
  final DateTime? activationDate;
  @override
  final DateTime? expiryDate;
  @override
  final DateTime? actualExpiryDate;
  @override
  final int? totalUses;
  @override
  final int usedUses;
  @override
  final int? remainingUses;
  @override
  final int status;
  @override
  final int? quotaUsed;
  @override
  final int? quotaLimit;
  @override
  final int? quotaPeriod;
  @override
  final DateTime? quotaPeriodStart;
  @override
  final DateTime? quotaPeriodEnd;
  @override
  final int usageLimitMode;

  @override
  String toString() {
    return 'ServicePurchase(id: $id, clientId: $clientId, clientName: $clientName, serviceId: $serviceId, serviceName: $serviceName, serviceCode: $serviceCode, serviceTypeCode: $serviceTypeCode, serviceTypeTitle: $serviceTypeTitle, executorSpecializationCode: $executorSpecializationCode, executorSpecializationTitle: $executorSpecializationTitle, purchasePrice: $purchasePrice, discountPercent: $discountPercent, discountAmount: $discountAmount, finalPrice: $finalPrice, paymentStatus: $paymentStatus, paymentSource: $paymentSource, purchaseDate: $purchaseDate, activationDate: $activationDate, expiryDate: $expiryDate, actualExpiryDate: $actualExpiryDate, totalUses: $totalUses, usedUses: $usedUses, remainingUses: $remainingUses, status: $status, quotaUsed: $quotaUsed, quotaLimit: $quotaLimit, quotaPeriod: $quotaPeriod, quotaPeriodStart: $quotaPeriodStart, quotaPeriodEnd: $quotaPeriodEnd, usageLimitMode: $usageLimitMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServicePurchaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.serviceCode, serviceCode) ||
                other.serviceCode == serviceCode) &&
            (identical(other.serviceTypeCode, serviceTypeCode) ||
                other.serviceTypeCode == serviceTypeCode) &&
            (identical(other.serviceTypeTitle, serviceTypeTitle) ||
                other.serviceTypeTitle == serviceTypeTitle) &&
            (identical(
                  other.executorSpecializationCode,
                  executorSpecializationCode,
                ) ||
                other.executorSpecializationCode ==
                    executorSpecializationCode) &&
            (identical(
                  other.executorSpecializationTitle,
                  executorSpecializationTitle,
                ) ||
                other.executorSpecializationTitle ==
                    executorSpecializationTitle) &&
            (identical(other.purchasePrice, purchasePrice) ||
                other.purchasePrice == purchasePrice) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.finalPrice, finalPrice) ||
                other.finalPrice == finalPrice) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentSource, paymentSource) ||
                other.paymentSource == paymentSource) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.activationDate, activationDate) ||
                other.activationDate == activationDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.actualExpiryDate, actualExpiryDate) ||
                other.actualExpiryDate == actualExpiryDate) &&
            (identical(other.totalUses, totalUses) ||
                other.totalUses == totalUses) &&
            (identical(other.usedUses, usedUses) ||
                other.usedUses == usedUses) &&
            (identical(other.remainingUses, remainingUses) ||
                other.remainingUses == remainingUses) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.quotaUsed, quotaUsed) ||
                other.quotaUsed == quotaUsed) &&
            (identical(other.quotaLimit, quotaLimit) ||
                other.quotaLimit == quotaLimit) &&
            (identical(other.quotaPeriod, quotaPeriod) ||
                other.quotaPeriod == quotaPeriod) &&
            (identical(other.quotaPeriodStart, quotaPeriodStart) ||
                other.quotaPeriodStart == quotaPeriodStart) &&
            (identical(other.quotaPeriodEnd, quotaPeriodEnd) ||
                other.quotaPeriodEnd == quotaPeriodEnd) &&
            (identical(other.usageLimitMode, usageLimitMode) ||
                other.usageLimitMode == usageLimitMode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    clientId,
    clientName,
    serviceId,
    serviceName,
    serviceCode,
    serviceTypeCode,
    serviceTypeTitle,
    executorSpecializationCode,
    executorSpecializationTitle,
    purchasePrice,
    discountPercent,
    discountAmount,
    finalPrice,
    paymentStatus,
    paymentSource,
    purchaseDate,
    activationDate,
    expiryDate,
    actualExpiryDate,
    totalUses,
    usedUses,
    remainingUses,
    status,
    quotaUsed,
    quotaLimit,
    quotaPeriod,
    quotaPeriodStart,
    quotaPeriodEnd,
    usageLimitMode,
  ]);

  /// Create a copy of ServicePurchase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServicePurchaseImplCopyWith<_$ServicePurchaseImpl> get copyWith =>
      __$$ServicePurchaseImplCopyWithImpl<_$ServicePurchaseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServicePurchaseImplToJson(this);
  }
}

abstract class _ServicePurchase implements ServicePurchase {
  const factory _ServicePurchase({
    required final String id,
    required final String clientId,
    final String? clientName,
    required final String serviceId,
    required final String serviceName,
    final String? serviceCode,
    final String? serviceTypeCode,
    final String? serviceTypeTitle,
    final String? executorSpecializationCode,
    final String? executorSpecializationTitle,
    final double? purchasePrice,
    required final double discountPercent,
    required final double discountAmount,
    final double? finalPrice,
    required final int paymentStatus,
    final int? paymentSource,
    required final DateTime purchaseDate,
    final DateTime? activationDate,
    final DateTime? expiryDate,
    final DateTime? actualExpiryDate,
    final int? totalUses,
    required final int usedUses,
    final int? remainingUses,
    required final int status,
    final int? quotaUsed,
    final int? quotaLimit,
    final int? quotaPeriod,
    final DateTime? quotaPeriodStart,
    final DateTime? quotaPeriodEnd,
    required final int usageLimitMode,
  }) = _$ServicePurchaseImpl;

  factory _ServicePurchase.fromJson(Map<String, dynamic> json) =
      _$ServicePurchaseImpl.fromJson;

  @override
  String get id;
  @override
  String get clientId;
  @override
  String? get clientName;
  @override
  String get serviceId;
  @override
  String get serviceName;
  @override
  String? get serviceCode;
  @override
  String? get serviceTypeCode;
  @override
  String? get serviceTypeTitle;
  @override
  String? get executorSpecializationCode;
  @override
  String? get executorSpecializationTitle;
  @override
  double? get purchasePrice;
  @override
  double get discountPercent;
  @override
  double get discountAmount;
  @override
  double? get finalPrice;
  @override
  int get paymentStatus;
  @override
  int? get paymentSource;
  @override
  DateTime get purchaseDate;
  @override
  DateTime? get activationDate;
  @override
  DateTime? get expiryDate;
  @override
  DateTime? get actualExpiryDate;
  @override
  int? get totalUses;
  @override
  int get usedUses;
  @override
  int? get remainingUses;
  @override
  int get status;
  @override
  int? get quotaUsed;
  @override
  int? get quotaLimit;
  @override
  int? get quotaPeriod;
  @override
  DateTime? get quotaPeriodStart;
  @override
  DateTime? get quotaPeriodEnd;
  @override
  int get usageLimitMode;

  /// Create a copy of ServicePurchase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServicePurchaseImplCopyWith<_$ServicePurchaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
