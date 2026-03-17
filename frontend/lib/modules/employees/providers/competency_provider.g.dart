// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$employeeCompetenciesHash() =>
    r'e6e913c4a9d68e5a64765fd53730cf2c236ceb2c';

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

abstract class _$EmployeeCompetencies
    extends BuildlessAutoDisposeAsyncNotifier<List<Competency>> {
  late final String employeeId;

  FutureOr<List<Competency>> build(String employeeId);
}

/// See also [EmployeeCompetencies].
@ProviderFor(EmployeeCompetencies)
const employeeCompetenciesProvider = EmployeeCompetenciesFamily();

/// See also [EmployeeCompetencies].
class EmployeeCompetenciesFamily extends Family<AsyncValue<List<Competency>>> {
  /// See also [EmployeeCompetencies].
  const EmployeeCompetenciesFamily();

  /// See also [EmployeeCompetencies].
  EmployeeCompetenciesProvider call(String employeeId) {
    return EmployeeCompetenciesProvider(employeeId);
  }

  @override
  EmployeeCompetenciesProvider getProviderOverride(
    covariant EmployeeCompetenciesProvider provider,
  ) {
    return call(provider.employeeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'employeeCompetenciesProvider';
}

/// See also [EmployeeCompetencies].
class EmployeeCompetenciesProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          EmployeeCompetencies,
          List<Competency>
        > {
  /// See also [EmployeeCompetencies].
  EmployeeCompetenciesProvider(String employeeId)
    : this._internal(
        () => EmployeeCompetencies()..employeeId = employeeId,
        from: employeeCompetenciesProvider,
        name: r'employeeCompetenciesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$employeeCompetenciesHash,
        dependencies: EmployeeCompetenciesFamily._dependencies,
        allTransitiveDependencies:
            EmployeeCompetenciesFamily._allTransitiveDependencies,
        employeeId: employeeId,
      );

  EmployeeCompetenciesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.employeeId,
  }) : super.internal();

  final String employeeId;

  @override
  FutureOr<List<Competency>> runNotifierBuild(
    covariant EmployeeCompetencies notifier,
  ) {
    return notifier.build(employeeId);
  }

  @override
  Override overrideWith(EmployeeCompetencies Function() create) {
    return ProviderOverride(
      origin: this,
      override: EmployeeCompetenciesProvider._internal(
        () => create()..employeeId = employeeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        employeeId: employeeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    EmployeeCompetencies,
    List<Competency>
  >
  createElement() {
    return _EmployeeCompetenciesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EmployeeCompetenciesProvider &&
        other.employeeId == employeeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, employeeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EmployeeCompetenciesRef
    on AutoDisposeAsyncNotifierProviderRef<List<Competency>> {
  /// The parameter `employeeId` of this provider.
  String get employeeId;
}

class _EmployeeCompetenciesProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          EmployeeCompetencies,
          List<Competency>
        >
    with EmployeeCompetenciesRef {
  _EmployeeCompetenciesProviderElement(super.provider);

  @override
  String get employeeId => (origin as EmployeeCompetenciesProvider).employeeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
