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

String _$imageFileHash() => r'0b4e745bd2c5a1798f14438d6286ea1e3b4a948c';

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

@ProviderFor(mainScreenContent)
const mainScreenContentProvider = MainScreenContentProvider._();

final class MainScreenContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Story>>,
          List<Story>,
          FutureOr<List<Story>>
        >
    with $FutureModifier<List<Story>>, $FutureProvider<List<Story>> {
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
  $FutureProviderElement<List<Story>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Story>> create(Ref ref) {
    return mainScreenContent(ref);
  }
}

String _$mainScreenContentHash() => r'd7f58ad57e9bff08d0fe4edd5bbdbf9ea8dfc651';
