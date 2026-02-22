// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_staff_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allSupportStaffHash() => r'886e64e2dd5d8c1bc4abe3b7a2078ed5c8ea6649';

/// See also [allSupportStaff].
@ProviderFor(allSupportStaff)
final allSupportStaffProvider =
    AutoDisposeFutureProvider<List<SupportStaff>>.internal(
      allSupportStaff,
      name: r'allSupportStaffProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allSupportStaffHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllSupportStaffRef = AutoDisposeFutureProviderRef<List<SupportStaff>>;
String _$supportStaffByIdHash() => r'72c17f157c474e1ffa5eabcf6cc067db0bc2c338';

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

/// See also [supportStaffById].
@ProviderFor(supportStaffById)
const supportStaffByIdProvider = SupportStaffByIdFamily();

/// See also [supportStaffById].
class SupportStaffByIdFamily extends Family<AsyncValue<SupportStaff>> {
  /// See also [supportStaffById].
  const SupportStaffByIdFamily();

  /// See also [supportStaffById].
  SupportStaffByIdProvider call(String id) {
    return SupportStaffByIdProvider(id);
  }

  @override
  SupportStaffByIdProvider getProviderOverride(
    covariant SupportStaffByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'supportStaffByIdProvider';
}

/// See also [supportStaffById].
class SupportStaffByIdProvider extends AutoDisposeFutureProvider<SupportStaff> {
  /// See also [supportStaffById].
  SupportStaffByIdProvider(String id)
    : this._internal(
        (ref) => supportStaffById(ref as SupportStaffByIdRef, id),
        from: supportStaffByIdProvider,
        name: r'supportStaffByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supportStaffByIdHash,
        dependencies: SupportStaffByIdFamily._dependencies,
        allTransitiveDependencies:
            SupportStaffByIdFamily._allTransitiveDependencies,
        id: id,
      );

  SupportStaffByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<SupportStaff> Function(SupportStaffByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupportStaffByIdProvider._internal(
        (ref) => create(ref as SupportStaffByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SupportStaff> createElement() {
    return _SupportStaffByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupportStaffByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupportStaffByIdRef on AutoDisposeFutureProviderRef<SupportStaff> {
  /// The parameter `id` of this provider.
  String get id;
}

class _SupportStaffByIdProviderElement
    extends AutoDisposeFutureProviderElement<SupportStaff>
    with SupportStaffByIdRef {
  _SupportStaffByIdProviderElement(super.provider);

  @override
  String get id => (origin as SupportStaffByIdProvider).id;
}

String _$supportStaffNotifierHash() =>
    r'ccf77977182cfb69da0d59663cef1f08ca192b2c';

/// See also [SupportStaffNotifier].
@ProviderFor(SupportStaffNotifier)
final supportStaffNotifierProvider =
    AsyncNotifierProvider<SupportStaffNotifier, void>.internal(
      SupportStaffNotifier.new,
      name: r'supportStaffNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supportStaffNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SupportStaffNotifier = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
