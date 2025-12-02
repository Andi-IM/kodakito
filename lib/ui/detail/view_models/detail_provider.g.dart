// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailScreenContent)
const detailScreenContentProvider = DetailScreenContentFamily._();

final class DetailScreenContentProvider
    extends $NotifierProvider<DetailScreenContent, Story> {
  const DetailScreenContentProvider._({
    required DetailScreenContentFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'detailScreenContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailScreenContentHash();

  @override
  String toString() {
    return r'detailScreenContentProvider'
        ''
        '($argument)';
  }

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

  @override
  bool operator ==(Object other) {
    return other is DetailScreenContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailScreenContentHash() =>
    r'5e3d12b0f3c393370b927dee0b702cacc27031d2';

final class DetailScreenContentFamily extends $Family
    with $ClassFamilyOverride<DetailScreenContent, Story, Story, Story, int> {
  const DetailScreenContentFamily._()
    : super(
        retry: null,
        name: r'detailScreenContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailScreenContentProvider call(int id) =>
      DetailScreenContentProvider._(argument: id, from: this);

  @override
  String toString() => r'detailScreenContentProvider';
}

abstract class _$DetailScreenContent extends $Notifier<Story> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  Story build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
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
