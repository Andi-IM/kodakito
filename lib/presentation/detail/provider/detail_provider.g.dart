// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailScreenContent)
const detailScreenContentProvider = DetailScreenContentProvider._();

final class DetailScreenContentProvider
    extends $NotifierProvider<DetailScreenContent, Story> {
  const DetailScreenContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailScreenContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailScreenContentHash();

  @$internal
  @override
  DetailScreenContent create() => DetailScreenContent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Story value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Story>(value),
    );
  }
}

String _$detailScreenContentHash() =>
    r'c532bb06c4be5ea4f9f1137c27d4afadf4c1da1f';

abstract class _$DetailScreenContent extends $Notifier<Story> {
  Story build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Story, Story>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Story, Story>,
              Story,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
