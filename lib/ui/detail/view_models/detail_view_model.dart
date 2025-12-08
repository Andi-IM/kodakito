import 'dart:typed_data' show Uint8List;

import 'package:dicoding_story/data/data_providers.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_view_model.g.dart';

@Riverpod()
class DetailScreenContent extends _$DetailScreenContent with LogMixin {
  NetworkImageService get _networkImageProvider =>
      ref.read(networkImageServiceProvider);
  DetailRepository get _repository => ref.read(detailRepositoryProvider);

  @override
  StoryState build(String id) {
    Future.microtask(() => fetchDetailStory(id));
    return const Initial();
  }

  Future<void> fetchDetailStory(String id) async {
    log.info('Fetching detail for story: $id');
    state = const Loading();
    final result = await _repository.getDetailStory(id);
    result.fold(
      (failure) {
        log.warning('Failed to fetch story detail: ${failure.message}');
        state = Error(errorMessage: failure.message);
      },
      (story) async {
        log.info('Successfully fetched story detail');
        final imageBytes = await _networkImageProvider.get(story.photoUrl);
        state = Loaded(story: story, imageBytes: imageBytes);
      },
    );
  }

  void resetState() {
    state = const Initial();
  }
}

class MockDetailContent extends _$DetailScreenContent
    with Mock
    implements DetailScreenContent {}

@riverpod
Future<ColorScheme?> storyColorScheme(Ref ref, Uint8List? imageBytes) async {
  if (imageBytes == null) {
    return null;
  }

  final generator = await PaletteGenerator.fromImageProvider(
    MemoryImage(imageBytes),
    size: const Size(200, 100),
  );

  if (generator.dominantColor != null) {
    return ColorScheme.fromSeed(
      seedColor: generator.dominantColor!.color,
      // We don't know the context brightness here, so we return a default.
      // We can adjust the brightness in the UI later.
    );
  }
  return null;
}
