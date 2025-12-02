// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storageService)
const storageServiceProvider = StorageServiceProvider._();

final class StorageServiceProvider
    extends
        $FunctionalProvider<
          SharedPrefsService,
          SharedPrefsService,
          SharedPrefsService
        >
    with $Provider<SharedPrefsService> {
  const StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  $ProviderElement<SharedPrefsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPrefsService create(Ref ref) {
    return storageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPrefsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPrefsService>(value),
    );
  }
}

String _$storageServiceHash() => r'1ed68de02f4d21d208188c52cfa0282257cba56a';

@ProviderFor(dioNetworkService)
const dioNetworkServiceProvider = DioNetworkServiceProvider._();

final class DioNetworkServiceProvider
    extends
        $FunctionalProvider<
          DioNetworkService,
          DioNetworkService,
          DioNetworkService
        >
    with $Provider<DioNetworkService> {
  const DioNetworkServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioNetworkServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioNetworkServiceHash();

  @$internal
  @override
  $ProviderElement<DioNetworkService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DioNetworkService create(Ref ref) {
    return dioNetworkService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DioNetworkService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DioNetworkService>(value),
    );
  }
}

String _$dioNetworkServiceHash() => r'7cfdb25d27b2e5d89667eccb3fef9d38d1598ce6';
