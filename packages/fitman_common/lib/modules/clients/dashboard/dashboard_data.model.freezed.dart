// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) {
  return _DashboardData.fromJson(json);
}

/// @nodoc
mixin _$DashboardData {
  NextTraining get nextTraining => throw _privateConstructorUsedError;
  TrainingProgress get trainingProgress => throw _privateConstructorUsedError;
  GoalProgress get goalProgress => throw _privateConstructorUsedError;
  List<Achievement> get achievements => throw _privateConstructorUsedError;

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
          DashboardData value, $Res Function(DashboardData) then) =
      _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call(
      {NextTraining nextTraining,
      TrainingProgress trainingProgress,
      GoalProgress goalProgress,
      List<Achievement> achievements});

  $NextTrainingCopyWith<$Res> get nextTraining;
  $TrainingProgressCopyWith<$Res> get trainingProgress;
  $GoalProgressCopyWith<$Res> get goalProgress;
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextTraining = null,
    Object? trainingProgress = null,
    Object? goalProgress = null,
    Object? achievements = null,
  }) {
    return _then(_value.copyWith(
      nextTraining: null == nextTraining
          ? _value.nextTraining
          : nextTraining // ignore: cast_nullable_to_non_nullable
              as NextTraining,
      trainingProgress: null == trainingProgress
          ? _value.trainingProgress
          : trainingProgress // ignore: cast_nullable_to_non_nullable
              as TrainingProgress,
      goalProgress: null == goalProgress
          ? _value.goalProgress
          : goalProgress // ignore: cast_nullable_to_non_nullable
              as GoalProgress,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
    ) as $Val);
  }

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NextTrainingCopyWith<$Res> get nextTraining {
    return $NextTrainingCopyWith<$Res>(_value.nextTraining, (value) {
      return _then(_value.copyWith(nextTraining: value) as $Val);
    });
  }

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainingProgressCopyWith<$Res> get trainingProgress {
    return $TrainingProgressCopyWith<$Res>(_value.trainingProgress, (value) {
      return _then(_value.copyWith(trainingProgress: value) as $Val);
    });
  }

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoalProgressCopyWith<$Res> get goalProgress {
    return $GoalProgressCopyWith<$Res>(_value.goalProgress, (value) {
      return _then(_value.copyWith(goalProgress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
          _$DashboardDataImpl value, $Res Function(_$DashboardDataImpl) then) =
      __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {NextTraining nextTraining,
      TrainingProgress trainingProgress,
      GoalProgress goalProgress,
      List<Achievement> achievements});

  @override
  $NextTrainingCopyWith<$Res> get nextTraining;
  @override
  $TrainingProgressCopyWith<$Res> get trainingProgress;
  @override
  $GoalProgressCopyWith<$Res> get goalProgress;
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
      _$DashboardDataImpl _value, $Res Function(_$DashboardDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextTraining = null,
    Object? trainingProgress = null,
    Object? goalProgress = null,
    Object? achievements = null,
  }) {
    return _then(_$DashboardDataImpl(
      nextTraining: null == nextTraining
          ? _value.nextTraining
          : nextTraining // ignore: cast_nullable_to_non_nullable
              as NextTraining,
      trainingProgress: null == trainingProgress
          ? _value.trainingProgress
          : trainingProgress // ignore: cast_nullable_to_non_nullable
              as TrainingProgress,
      goalProgress: null == goalProgress
          ? _value.goalProgress
          : goalProgress // ignore: cast_nullable_to_non_nullable
              as GoalProgress,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl(
      {required this.nextTraining,
      required this.trainingProgress,
      required this.goalProgress,
      required final List<Achievement> achievements})
      : _achievements = achievements;

  factory _$DashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataImplFromJson(json);

  @override
  final NextTraining nextTraining;
  @override
  final TrainingProgress trainingProgress;
  @override
  final GoalProgress goalProgress;
  final List<Achievement> _achievements;
  @override
  List<Achievement> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  @override
  String toString() {
    return 'DashboardData(nextTraining: $nextTraining, trainingProgress: $trainingProgress, goalProgress: $goalProgress, achievements: $achievements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.nextTraining, nextTraining) ||
                other.nextTraining == nextTraining) &&
            (identical(other.trainingProgress, trainingProgress) ||
                other.trainingProgress == trainingProgress) &&
            (identical(other.goalProgress, goalProgress) ||
                other.goalProgress == goalProgress) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nextTraining, trainingProgress,
      goalProgress, const DeepCollectionEquality().hash(_achievements));

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataImplToJson(
      this,
    );
  }
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData(
      {required final NextTraining nextTraining,
      required final TrainingProgress trainingProgress,
      required final GoalProgress goalProgress,
      required final List<Achievement> achievements}) = _$DashboardDataImpl;

  factory _DashboardData.fromJson(Map<String, dynamic> json) =
      _$DashboardDataImpl.fromJson;

  @override
  NextTraining get nextTraining;
  @override
  TrainingProgress get trainingProgress;
  @override
  GoalProgress get goalProgress;
  @override
  List<Achievement> get achievements;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NextTraining _$NextTrainingFromJson(Map<String, dynamic> json) {
  return _NextTraining.fromJson(json);
}

/// @nodoc
mixin _$NextTraining {
  String get title => throw _privateConstructorUsedError;
  DateTime get time => throw _privateConstructorUsedError;

  /// Serializes this NextTraining to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NextTraining
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NextTrainingCopyWith<NextTraining> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NextTrainingCopyWith<$Res> {
  factory $NextTrainingCopyWith(
          NextTraining value, $Res Function(NextTraining) then) =
      _$NextTrainingCopyWithImpl<$Res, NextTraining>;
  @useResult
  $Res call({String title, DateTime time});
}

/// @nodoc
class _$NextTrainingCopyWithImpl<$Res, $Val extends NextTraining>
    implements $NextTrainingCopyWith<$Res> {
  _$NextTrainingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NextTraining
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NextTrainingImplCopyWith<$Res>
    implements $NextTrainingCopyWith<$Res> {
  factory _$$NextTrainingImplCopyWith(
          _$NextTrainingImpl value, $Res Function(_$NextTrainingImpl) then) =
      __$$NextTrainingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, DateTime time});
}

/// @nodoc
class __$$NextTrainingImplCopyWithImpl<$Res>
    extends _$NextTrainingCopyWithImpl<$Res, _$NextTrainingImpl>
    implements _$$NextTrainingImplCopyWith<$Res> {
  __$$NextTrainingImplCopyWithImpl(
      _$NextTrainingImpl _value, $Res Function(_$NextTrainingImpl) _then)
      : super(_value, _then);

  /// Create a copy of NextTraining
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? time = null,
  }) {
    return _then(_$NextTrainingImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NextTrainingImpl implements _NextTraining {
  const _$NextTrainingImpl({required this.title, required this.time});

  factory _$NextTrainingImpl.fromJson(Map<String, dynamic> json) =>
      _$$NextTrainingImplFromJson(json);

  @override
  final String title;
  @override
  final DateTime time;

  @override
  String toString() {
    return 'NextTraining(title: $title, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NextTrainingImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, time);

  /// Create a copy of NextTraining
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NextTrainingImplCopyWith<_$NextTrainingImpl> get copyWith =>
      __$$NextTrainingImplCopyWithImpl<_$NextTrainingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NextTrainingImplToJson(
      this,
    );
  }
}

abstract class _NextTraining implements NextTraining {
  const factory _NextTraining(
      {required final String title,
      required final DateTime time}) = _$NextTrainingImpl;

  factory _NextTraining.fromJson(Map<String, dynamic> json) =
      _$NextTrainingImpl.fromJson;

  @override
  String get title;
  @override
  DateTime get time;

  /// Create a copy of NextTraining
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NextTrainingImplCopyWith<_$NextTrainingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainingProgress _$TrainingProgressFromJson(Map<String, dynamic> json) {
  return _TrainingProgress.fromJson(json);
}

/// @nodoc
mixin _$TrainingProgress {
  int get completed => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get caloriesBurned => throw _privateConstructorUsedError;
  int get attendance => throw _privateConstructorUsedError;

  /// Serializes this TrainingProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingProgressCopyWith<TrainingProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingProgressCopyWith<$Res> {
  factory $TrainingProgressCopyWith(
          TrainingProgress value, $Res Function(TrainingProgress) then) =
      _$TrainingProgressCopyWithImpl<$Res, TrainingProgress>;
  @useResult
  $Res call({int completed, int total, int caloriesBurned, int attendance});
}

/// @nodoc
class _$TrainingProgressCopyWithImpl<$Res, $Val extends TrainingProgress>
    implements $TrainingProgressCopyWith<$Res> {
  _$TrainingProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completed = null,
    Object? total = null,
    Object? caloriesBurned = null,
    Object? attendance = null,
  }) {
    return _then(_value.copyWith(
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesBurned: null == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      attendance: null == attendance
          ? _value.attendance
          : attendance // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingProgressImplCopyWith<$Res>
    implements $TrainingProgressCopyWith<$Res> {
  factory _$$TrainingProgressImplCopyWith(_$TrainingProgressImpl value,
          $Res Function(_$TrainingProgressImpl) then) =
      __$$TrainingProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int completed, int total, int caloriesBurned, int attendance});
}

/// @nodoc
class __$$TrainingProgressImplCopyWithImpl<$Res>
    extends _$TrainingProgressCopyWithImpl<$Res, _$TrainingProgressImpl>
    implements _$$TrainingProgressImplCopyWith<$Res> {
  __$$TrainingProgressImplCopyWithImpl(_$TrainingProgressImpl _value,
      $Res Function(_$TrainingProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrainingProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completed = null,
    Object? total = null,
    Object? caloriesBurned = null,
    Object? attendance = null,
  }) {
    return _then(_$TrainingProgressImpl(
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesBurned: null == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int,
      attendance: null == attendance
          ? _value.attendance
          : attendance // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingProgressImpl implements _TrainingProgress {
  const _$TrainingProgressImpl(
      {required this.completed,
      required this.total,
      required this.caloriesBurned,
      required this.attendance});

  factory _$TrainingProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingProgressImplFromJson(json);

  @override
  final int completed;
  @override
  final int total;
  @override
  final int caloriesBurned;
  @override
  final int attendance;

  @override
  String toString() {
    return 'TrainingProgress(completed: $completed, total: $total, caloriesBurned: $caloriesBurned, attendance: $attendance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingProgressImpl &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            (identical(other.attendance, attendance) ||
                other.attendance == attendance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, completed, total, caloriesBurned, attendance);

  /// Create a copy of TrainingProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingProgressImplCopyWith<_$TrainingProgressImpl> get copyWith =>
      __$$TrainingProgressImplCopyWithImpl<_$TrainingProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingProgressImplToJson(
      this,
    );
  }
}

abstract class _TrainingProgress implements TrainingProgress {
  const factory _TrainingProgress(
      {required final int completed,
      required final int total,
      required final int caloriesBurned,
      required final int attendance}) = _$TrainingProgressImpl;

  factory _TrainingProgress.fromJson(Map<String, dynamic> json) =
      _$TrainingProgressImpl.fromJson;

  @override
  int get completed;
  @override
  int get total;
  @override
  int get caloriesBurned;
  @override
  int get attendance;

  /// Create a copy of TrainingProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingProgressImplCopyWith<_$TrainingProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalProgress _$GoalProgressFromJson(Map<String, dynamic> json) {
  return _GoalProgress.fromJson(json);
}

/// @nodoc
mixin _$GoalProgress {
  String get goal => throw _privateConstructorUsedError;
  double get currentWeight => throw _privateConstructorUsedError;
  double get targetWeight => throw _privateConstructorUsedError;
  int get avgDeficit => throw _privateConstructorUsedError;

  /// Serializes this GoalProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalProgressCopyWith<GoalProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalProgressCopyWith<$Res> {
  factory $GoalProgressCopyWith(
          GoalProgress value, $Res Function(GoalProgress) then) =
      _$GoalProgressCopyWithImpl<$Res, GoalProgress>;
  @useResult
  $Res call(
      {String goal, double currentWeight, double targetWeight, int avgDeficit});
}

/// @nodoc
class _$GoalProgressCopyWithImpl<$Res, $Val extends GoalProgress>
    implements $GoalProgressCopyWith<$Res> {
  _$GoalProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? currentWeight = null,
    Object? targetWeight = null,
    Object? avgDeficit = null,
  }) {
    return _then(_value.copyWith(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      avgDeficit: null == avgDeficit
          ? _value.avgDeficit
          : avgDeficit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalProgressImplCopyWith<$Res>
    implements $GoalProgressCopyWith<$Res> {
  factory _$$GoalProgressImplCopyWith(
          _$GoalProgressImpl value, $Res Function(_$GoalProgressImpl) then) =
      __$$GoalProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String goal, double currentWeight, double targetWeight, int avgDeficit});
}

/// @nodoc
class __$$GoalProgressImplCopyWithImpl<$Res>
    extends _$GoalProgressCopyWithImpl<$Res, _$GoalProgressImpl>
    implements _$$GoalProgressImplCopyWith<$Res> {
  __$$GoalProgressImplCopyWithImpl(
      _$GoalProgressImpl _value, $Res Function(_$GoalProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? currentWeight = null,
    Object? targetWeight = null,
    Object? avgDeficit = null,
  }) {
    return _then(_$GoalProgressImpl(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      avgDeficit: null == avgDeficit
          ? _value.avgDeficit
          : avgDeficit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalProgressImpl implements _GoalProgress {
  const _$GoalProgressImpl(
      {required this.goal,
      required this.currentWeight,
      required this.targetWeight,
      required this.avgDeficit});

  factory _$GoalProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalProgressImplFromJson(json);

  @override
  final String goal;
  @override
  final double currentWeight;
  @override
  final double targetWeight;
  @override
  final int avgDeficit;

  @override
  String toString() {
    return 'GoalProgress(goal: $goal, currentWeight: $currentWeight, targetWeight: $targetWeight, avgDeficit: $avgDeficit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalProgressImpl &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.avgDeficit, avgDeficit) ||
                other.avgDeficit == avgDeficit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, goal, currentWeight, targetWeight, avgDeficit);

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalProgressImplCopyWith<_$GoalProgressImpl> get copyWith =>
      __$$GoalProgressImplCopyWithImpl<_$GoalProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalProgressImplToJson(
      this,
    );
  }
}

abstract class _GoalProgress implements GoalProgress {
  const factory _GoalProgress(
      {required final String goal,
      required final double currentWeight,
      required final double targetWeight,
      required final int avgDeficit}) = _$GoalProgressImpl;

  factory _GoalProgress.fromJson(Map<String, dynamic> json) =
      _$GoalProgressImpl.fromJson;

  @override
  String get goal;
  @override
  double get currentWeight;
  @override
  double get targetWeight;
  @override
  int get avgDeficit;

  /// Create a copy of GoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalProgressImplCopyWith<_$GoalProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  String get icon => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call({String icon, String color});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? color = null,
  }) {
    return _then(_value.copyWith(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String icon, String color});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? color = null,
  }) {
    return _then(_$AchievementImpl(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl({required this.icon, required this.color});

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final String icon;
  @override
  final String color;

  @override
  String toString() {
    return 'Achievement(icon: $icon, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, icon, color);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {required final String icon,
      required final String color}) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  String get icon;
  @override
  String get color;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
