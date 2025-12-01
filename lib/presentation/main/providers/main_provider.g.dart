// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImageFile)
const imageFileProvider = ImageFileProvider._();

final class ImageFileProvider extends $NotifierProvider<ImageFile, Uint8List?> {
  const ImageFileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageFileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageFileHash();

  @$internal
  @override
  ImageFile create() => ImageFile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uint8List? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uint8List?>(value),
    );
  }
}

String _$imageFileHash() => r'd9e8479cba88f815cc025da1d655b3918992ce90';

abstract class _$ImageFile extends $Notifier<Uint8List?> {
  Uint8List? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Uint8List?, Uint8List?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Uint8List?, Uint8List?>,
              Uint8List?,
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

String _$mainScreenContentHash() => r'3a91925a468d9a25f4c10f5fce923990cc029936';

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
