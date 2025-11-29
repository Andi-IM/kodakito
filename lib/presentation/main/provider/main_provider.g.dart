// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavigationData)
const navigationDataProvider = NavigationDataProvider._();

final class NavigationDataProvider
    extends $NotifierProvider<NavigationData, NavigationRailM3EType> {
  const NavigationDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationDataHash();

  @$internal
  @override
  NavigationData create() => NavigationData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationRailM3EType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationRailM3EType>(value),
    );
  }
}

String _$navigationDataHash() => r'f708886b80830fbf4c27245d926eeb413aa9c24f';

abstract class _$NavigationData extends $Notifier<NavigationRailM3EType> {
  NavigationRailM3EType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NavigationRailM3EType, NavigationRailM3EType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationRailM3EType, NavigationRailM3EType>,
              NavigationRailM3EType,
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
