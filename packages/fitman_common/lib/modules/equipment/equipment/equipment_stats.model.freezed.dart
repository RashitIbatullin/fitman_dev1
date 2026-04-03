// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_stats.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EquipmentStats {
  int get total => throw _privateConstructorUsedError;
  int get available => throw _privateConstructorUsedError;
  int get inUse => throw _privateConstructorUsedError;
  int get inMaintenance => throw _privateConstructorUsedError;
  int get outOfOrder => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentStatsCopyWith<EquipmentStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentStatsCopyWith<$Res> {
  factory $EquipmentStatsCopyWith(
          EquipmentStats value, $Res Function(EquipmentStats) then) =
      _$EquipmentStatsCopyWithImpl<$Res, EquipmentStats>;
  @useResult
  $Res call(
      {int total, int available, int inUse, int inMaintenance, int outOfOrder});
}

/// @nodoc
class _$EquipmentStatsCopyWithImpl<$Res, $Val extends EquipmentStats>
    implements $EquipmentStatsCopyWith<$Res> {
  _$EquipmentStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? available = null,
    Object? inUse = null,
    Object? inMaintenance = null,
    Object? outOfOrder = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      inUse: null == inUse
          ? _value.inUse
          : inUse // ignore: cast_nullable_to_non_nullable
              as int,
      inMaintenance: null == inMaintenance
          ? _value.inMaintenance
          : inMaintenance // ignore: cast_nullable_to_non_nullable
              as int,
      outOfOrder: null == outOfOrder
          ? _value.outOfOrder
          : outOfOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EquipmentStatsImplCopyWith<$Res>
    implements $EquipmentStatsCopyWith<$Res> {
  factory _$$EquipmentStatsImplCopyWith(_$EquipmentStatsImpl value,
          $Res Function(_$EquipmentStatsImpl) then) =
      __$$EquipmentStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total, int available, int inUse, int inMaintenance, int outOfOrder});
}

/// @nodoc
class __$$EquipmentStatsImplCopyWithImpl<$Res>
    extends _$EquipmentStatsCopyWithImpl<$Res, _$EquipmentStatsImpl>
    implements _$$EquipmentStatsImplCopyWith<$Res> {
  __$$EquipmentStatsImplCopyWithImpl(
      _$EquipmentStatsImpl _value, $Res Function(_$EquipmentStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of EquipmentStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? available = null,
    Object? inUse = null,
    Object? inMaintenance = null,
    Object? outOfOrder = null,
  }) {
    return _then(_$EquipmentStatsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      inUse: null == inUse
          ? _value.inUse
          : inUse // ignore: cast_nullable_to_non_nullable
              as int,
      inMaintenance: null == inMaintenance
          ? _value.inMaintenance
          : inMaintenance // ignore: cast_nullable_to_non_nullable
              as int,
      outOfOrder: null == outOfOrder
          ? _value.outOfOrder
          : outOfOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$EquipmentStatsImpl implements _EquipmentStats {
  const _$EquipmentStatsImpl(
      {required this.total,
      required this.available,
      required this.inUse,
      required this.inMaintenance,
      required this.outOfOrder});

  @override
  final int total;
  @override
  final int available;
  @override
  final int inUse;
  @override
  final int inMaintenance;
  @override
  final int outOfOrder;

  @override
  String toString() {
    return 'EquipmentStats(total: $total, available: $available, inUse: $inUse, inMaintenance: $inMaintenance, outOfOrder: $outOfOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentStatsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.inUse, inUse) || other.inUse == inUse) &&
            (identical(other.inMaintenance, inMaintenance) ||
                other.inMaintenance == inMaintenance) &&
            (identical(other.outOfOrder, outOfOrder) ||
                other.outOfOrder == outOfOrder));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, total, available, inUse, inMaintenance, outOfOrder);

  /// Create a copy of EquipmentStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentStatsImplCopyWith<_$EquipmentStatsImpl> get copyWith =>
      __$$EquipmentStatsImplCopyWithImpl<_$EquipmentStatsImpl>(
          this, _$identity);
}

abstract class _EquipmentStats implements EquipmentStats {
  const factory _EquipmentStats(
      {required final int total,
      required final int available,
      required final int inUse,
      required final int inMaintenance,
      required final int outOfOrder}) = _$EquipmentStatsImpl;

  @override
  int get total;
  @override
  int get available;
  @override
  int get inUse;
  @override
  int get inMaintenance;
  @override
  int get outOfOrder;

  /// Create a copy of EquipmentStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentStatsImplCopyWith<_$EquipmentStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
