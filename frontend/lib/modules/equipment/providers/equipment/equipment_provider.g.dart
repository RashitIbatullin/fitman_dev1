// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$equipmentStatsHash() => r'ec7dd86060cc0bbaa5ed232af54ded4402e7345b';

/// See also [equipmentStats].
@ProviderFor(equipmentStats)
final equipmentStatsProvider = AutoDisposeProvider<EquipmentStats>.internal(
  equipmentStats,
  name: r'equipmentStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$equipmentStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EquipmentStatsRef = AutoDisposeProviderRef<EquipmentStats>;
String _$filteredDashboardEquipmentHash() =>
    r'b98d4d3c4dbe50683d11ea3a5871b16973cf62e3';

/// See also [filteredDashboardEquipment].
@ProviderFor(filteredDashboardEquipment)
final filteredDashboardEquipmentProvider =
    AutoDisposeProvider<List<EquipmentItem>>.internal(
      filteredDashboardEquipment,
      name: r'filteredDashboardEquipmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredDashboardEquipmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredDashboardEquipmentRef =
    AutoDisposeProviderRef<List<EquipmentItem>>;
String _$equipmentHash() => r'98101741a359db7fff2f4496a841818ea34d87f3';

/// See also [Equipment].
@ProviderFor(Equipment)
final equipmentProvider =
    AutoDisposeAsyncNotifierProvider<Equipment, void>.internal(
      Equipment.new,
      name: r'equipmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$equipmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Equipment = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
