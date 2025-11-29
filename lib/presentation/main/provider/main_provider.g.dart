// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IndexNav)
const indexNavProvider = IndexNavProvider._();

final class IndexNavProvider extends $NotifierProvider<IndexNav, int> {
  const IndexNavProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indexNavProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indexNavHash();

  @$internal
  @override
  IndexNav create() => IndexNav();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$indexNavHash() => r'011e7547cf4543bcc68e929c6e97b21a9ad8398e';

abstract class _$IndexNav extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MainScreenContent)
const mainScreenContentProvider = MainScreenContentProvider._();

final class MainScreenContentProvider
    extends $NotifierProvider<MainScreenContent, List<Story>> {
  const MainScreenContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainScreenContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainScreenContentHash();

  @$internal
  @override
  MainScreenContent create() => MainScreenContent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Story> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Story>>(value),
    );
  }
}

String _$mainScreenContentHash() => r'58a1f7e29e2e269dd7902f1c301308fa9c0f5490';

abstract class _$MainScreenContent extends $Notifier<List<Story>> {
  List<Story> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Story>, List<Story>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Story>, List<Story>>,
              List<Story>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
