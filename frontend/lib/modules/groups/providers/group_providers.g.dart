// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainingGroupTypesHash() =>
    r'de323388739fb8043cd0e1696b8efdfb9815b83c';

/// See also [trainingGroupTypes].
@ProviderFor(trainingGroupTypes)
final trainingGroupTypesProvider =
    FutureProvider<List<TrainingGroupType>>.internal(
      trainingGroupTypes,
      name: r'trainingGroupTypesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainingGroupTypesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrainingGroupTypesRef = FutureProviderRef<List<TrainingGroupType>>;
String _$analyticGroupsHash() => r'563df3685cb84ce2c3a50dad69d28ef7fe96ab81';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AnalyticGroups
    extends BuildlessAsyncNotifier<List<AnalyticGroup>> {
  late final String searchQuery;
  late final bool? isArchived;

  FutureOr<List<AnalyticGroup>> build({
    String searchQuery = '',
    bool? isArchived,
  });
}

/// See also [AnalyticGroups].
@ProviderFor(AnalyticGroups)
const analyticGroupsProvider = AnalyticGroupsFamily();

/// See also [AnalyticGroups].
class AnalyticGroupsFamily extends Family<AsyncValue<List<AnalyticGroup>>> {
  /// See also [AnalyticGroups].
  const AnalyticGroupsFamily();

  /// See also [AnalyticGroups].
  AnalyticGroupsProvider call({String searchQuery = '', bool? isArchived}) {
    return AnalyticGroupsProvider(
      searchQuery: searchQuery,
      isArchived: isArchived,
    );
  }

  @override
  AnalyticGroupsProvider getProviderOverride(
    covariant AnalyticGroupsProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      isArchived: provider.isArchived,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'analyticGroupsProvider';
}

/// See also [AnalyticGroups].
class AnalyticGroupsProvider
    extends AsyncNotifierProviderImpl<AnalyticGroups, List<AnalyticGroup>> {
  /// See also [AnalyticGroups].
  AnalyticGroupsProvider({String searchQuery = '', bool? isArchived})
    : this._internal(
        () => AnalyticGroups()
          ..searchQuery = searchQuery
          ..isArchived = isArchived,
        from: analyticGroupsProvider,
        name: r'analyticGroupsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$analyticGroupsHash,
        dependencies: AnalyticGroupsFamily._dependencies,
        allTransitiveDependencies:
            AnalyticGroupsFamily._allTransitiveDependencies,
        searchQuery: searchQuery,
        isArchived: isArchived,
      );

  AnalyticGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.isArchived,
  }) : super.internal();

  final String searchQuery;
  final bool? isArchived;

  @override
  FutureOr<List<AnalyticGroup>> runNotifierBuild(
    covariant AnalyticGroups notifier,
  ) {
    return notifier.build(searchQuery: searchQuery, isArchived: isArchived);
  }

  @override
  Override overrideWith(AnalyticGroups Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnalyticGroupsProvider._internal(
        () => create()
          ..searchQuery = searchQuery
          ..isArchived = isArchived,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        isArchived: isArchived,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<AnalyticGroups, List<AnalyticGroup>>
  createElement() {
    return _AnalyticGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnalyticGroupsProvider &&
        other.searchQuery == searchQuery &&
        other.isArchived == isArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, isArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnalyticGroupsRef on AsyncNotifierProviderRef<List<AnalyticGroup>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;

  /// The parameter `isArchived` of this provider.
  bool? get isArchived;
}

class _AnalyticGroupsProviderElement
    extends AsyncNotifierProviderElement<AnalyticGroups, List<AnalyticGroup>>
    with AnalyticGroupsRef {
  _AnalyticGroupsProviderElement(super.provider);

  @override
  String get searchQuery => (origin as AnalyticGroupsProvider).searchQuery;
  @override
  bool? get isArchived => (origin as AnalyticGroupsProvider).isArchived;
}

String _$trainingGroupsHash() => r'cc28fc7f4cb0106484ffdd8a824ef52e18b0b0fb';

abstract class _$TrainingGroups
    extends BuildlessAsyncNotifier<List<TrainingGroup>> {
  late final String searchQuery;
  late final int? groupTypeId;
  late final bool? isActive;
  late final bool? isArchived;
  late final int? trainerId;
  late final int? instructorId;
  late final int? managerId;

  FutureOr<List<TrainingGroup>> build({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  });
}

/// See also [TrainingGroups].
@ProviderFor(TrainingGroups)
const trainingGroupsProvider = TrainingGroupsFamily();

/// See also [TrainingGroups].
class TrainingGroupsFamily extends Family<AsyncValue<List<TrainingGroup>>> {
  /// See also [TrainingGroups].
  const TrainingGroupsFamily();

  /// See also [TrainingGroups].
  TrainingGroupsProvider call({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  }) {
    return TrainingGroupsProvider(
      searchQuery: searchQuery,
      groupTypeId: groupTypeId,
      isActive: isActive,
      isArchived: isArchived,
      trainerId: trainerId,
      instructorId: instructorId,
      managerId: managerId,
    );
  }

  @override
  TrainingGroupsProvider getProviderOverride(
    covariant TrainingGroupsProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      groupTypeId: provider.groupTypeId,
      isActive: provider.isActive,
      isArchived: provider.isArchived,
      trainerId: provider.trainerId,
      instructorId: provider.instructorId,
      managerId: provider.managerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trainingGroupsProvider';
}

/// See also [TrainingGroups].
class TrainingGroupsProvider
    extends AsyncNotifierProviderImpl<TrainingGroups, List<TrainingGroup>> {
  /// See also [TrainingGroups].
  TrainingGroupsProvider({
    String searchQuery = '',
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  }) : this._internal(
         () => TrainingGroups()
           ..searchQuery = searchQuery
           ..groupTypeId = groupTypeId
           ..isActive = isActive
           ..isArchived = isArchived
           ..trainerId = trainerId
           ..instructorId = instructorId
           ..managerId = managerId,
         from: trainingGroupsProvider,
         name: r'trainingGroupsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$trainingGroupsHash,
         dependencies: TrainingGroupsFamily._dependencies,
         allTransitiveDependencies:
             TrainingGroupsFamily._allTransitiveDependencies,
         searchQuery: searchQuery,
         groupTypeId: groupTypeId,
         isActive: isActive,
         isArchived: isArchived,
         trainerId: trainerId,
         instructorId: instructorId,
         managerId: managerId,
       );

  TrainingGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.groupTypeId,
    required this.isActive,
    required this.isArchived,
    required this.trainerId,
    required this.instructorId,
    required this.managerId,
  }) : super.internal();

  final String searchQuery;
  final int? groupTypeId;
  final bool? isActive;
  final bool? isArchived;
  final int? trainerId;
  final int? instructorId;
  final int? managerId;

  @override
  FutureOr<List<TrainingGroup>> runNotifierBuild(
    covariant TrainingGroups notifier,
  ) {
    return notifier.build(
      searchQuery: searchQuery,
      groupTypeId: groupTypeId,
      isActive: isActive,
      isArchived: isArchived,
      trainerId: trainerId,
      instructorId: instructorId,
      managerId: managerId,
    );
  }

  @override
  Override overrideWith(TrainingGroups Function() create) {
    return ProviderOverride(
      origin: this,
      override: TrainingGroupsProvider._internal(
        () => create()
          ..searchQuery = searchQuery
          ..groupTypeId = groupTypeId
          ..isActive = isActive
          ..isArchived = isArchived
          ..trainerId = trainerId
          ..instructorId = instructorId
          ..managerId = managerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        groupTypeId: groupTypeId,
        isActive: isActive,
        isArchived: isArchived,
        trainerId: trainerId,
        instructorId: instructorId,
        managerId: managerId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<TrainingGroups, List<TrainingGroup>>
  createElement() {
    return _TrainingGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainingGroupsProvider &&
        other.searchQuery == searchQuery &&
        other.groupTypeId == groupTypeId &&
        other.isActive == isActive &&
        other.isArchived == isArchived &&
        other.trainerId == trainerId &&
        other.instructorId == instructorId &&
        other.managerId == managerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, groupTypeId.hashCode);
    hash = _SystemHash.combine(hash, isActive.hashCode);
    hash = _SystemHash.combine(hash, isArchived.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);
    hash = _SystemHash.combine(hash, instructorId.hashCode);
    hash = _SystemHash.combine(hash, managerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrainingGroupsRef on AsyncNotifierProviderRef<List<TrainingGroup>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;

  /// The parameter `groupTypeId` of this provider.
  int? get groupTypeId;

  /// The parameter `isActive` of this provider.
  bool? get isActive;

  /// The parameter `isArchived` of this provider.
  bool? get isArchived;

  /// The parameter `trainerId` of this provider.
  int? get trainerId;

  /// The parameter `instructorId` of this provider.
  int? get instructorId;

  /// The parameter `managerId` of this provider.
  int? get managerId;
}

class _TrainingGroupsProviderElement
    extends AsyncNotifierProviderElement<TrainingGroups, List<TrainingGroup>>
    with TrainingGroupsRef {
  _TrainingGroupsProviderElement(super.provider);

  @override
  String get searchQuery => (origin as TrainingGroupsProvider).searchQuery;
  @override
  int? get groupTypeId => (origin as TrainingGroupsProvider).groupTypeId;
  @override
  bool? get isActive => (origin as TrainingGroupsProvider).isActive;
  @override
  bool? get isArchived => (origin as TrainingGroupsProvider).isArchived;
  @override
  int? get trainerId => (origin as TrainingGroupsProvider).trainerId;
  @override
  int? get instructorId => (origin as TrainingGroupsProvider).instructorId;
  @override
  int? get managerId => (origin as TrainingGroupsProvider).managerId;
}

String _$groupSchedulesHash() => r'4e263b5e213fcadcbc3edc7e8775e09fd0495102';

abstract class _$GroupSchedules
    extends BuildlessAsyncNotifier<List<GroupSchedule>> {
  late final int groupId;

  FutureOr<List<GroupSchedule>> build(int groupId);
}

/// See also [GroupSchedules].
@ProviderFor(GroupSchedules)
const groupSchedulesProvider = GroupSchedulesFamily();

/// See also [GroupSchedules].
class GroupSchedulesFamily extends Family<AsyncValue<List<GroupSchedule>>> {
  /// See also [GroupSchedules].
  const GroupSchedulesFamily();

  /// See also [GroupSchedules].
  GroupSchedulesProvider call(int groupId) {
    return GroupSchedulesProvider(groupId);
  }

  @override
  GroupSchedulesProvider getProviderOverride(
    covariant GroupSchedulesProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupSchedulesProvider';
}

/// See also [GroupSchedules].
class GroupSchedulesProvider
    extends AsyncNotifierProviderImpl<GroupSchedules, List<GroupSchedule>> {
  /// See also [GroupSchedules].
  GroupSchedulesProvider(int groupId)
    : this._internal(
        () => GroupSchedules()..groupId = groupId,
        from: groupSchedulesProvider,
        name: r'groupSchedulesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupSchedulesHash,
        dependencies: GroupSchedulesFamily._dependencies,
        allTransitiveDependencies:
            GroupSchedulesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupSchedulesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final int groupId;

  @override
  FutureOr<List<GroupSchedule>> runNotifierBuild(
    covariant GroupSchedules notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupSchedules Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupSchedulesProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<GroupSchedules, List<GroupSchedule>>
  createElement() {
    return _GroupSchedulesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupSchedulesProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupSchedulesRef on AsyncNotifierProviderRef<List<GroupSchedule>> {
  /// The parameter `groupId` of this provider.
  int get groupId;
}

class _GroupSchedulesProviderElement
    extends AsyncNotifierProviderElement<GroupSchedules, List<GroupSchedule>>
    with GroupSchedulesRef {
  _GroupSchedulesProviderElement(super.provider);

  @override
  int get groupId => (origin as GroupSchedulesProvider).groupId;
}

String _$groupMembersHash() => r'7330755538d25fab6de6ed7c415838fa9e69c86d';

abstract class _$GroupMembers extends BuildlessAsyncNotifier<List<int>> {
  late final int groupId;

  FutureOr<List<int>> build(int groupId);
}

/// See also [GroupMembers].
@ProviderFor(GroupMembers)
const groupMembersProvider = GroupMembersFamily();

/// See also [GroupMembers].
class GroupMembersFamily extends Family<AsyncValue<List<int>>> {
  /// See also [GroupMembers].
  const GroupMembersFamily();

  /// See also [GroupMembers].
  GroupMembersProvider call(int groupId) {
    return GroupMembersProvider(groupId);
  }

  @override
  GroupMembersProvider getProviderOverride(
    covariant GroupMembersProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupMembersProvider';
}

/// See also [GroupMembers].
class GroupMembersProvider
    extends AsyncNotifierProviderImpl<GroupMembers, List<int>> {
  /// See also [GroupMembers].
  GroupMembersProvider(int groupId)
    : this._internal(
        () => GroupMembers()..groupId = groupId,
        from: groupMembersProvider,
        name: r'groupMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupMembersHash,
        dependencies: GroupMembersFamily._dependencies,
        allTransitiveDependencies:
            GroupMembersFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final int groupId;

  @override
  FutureOr<List<int>> runNotifierBuild(covariant GroupMembers notifier) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupMembersProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<GroupMembers, List<int>> createElement() {
    return _GroupMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupMembersRef on AsyncNotifierProviderRef<List<int>> {
  /// The parameter `groupId` of this provider.
  int get groupId;
}

class _GroupMembersProviderElement
    extends AsyncNotifierProviderElement<GroupMembers, List<int>>
    with GroupMembersRef {
  _GroupMembersProviderElement(super.provider);

  @override
  int get groupId => (origin as GroupMembersProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
