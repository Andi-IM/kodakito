import 'dart:io';

import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_view_model.g.dart';

@riverpod
class ImageFile extends _$ImageFile {
  @override
  Uint8List? build() {
    return null;
  }

  void setImageFile(Uint8List imageFile) {
    state = imageFile;
  }

  Future<XFile?> toFile() async {
    final bytes = state;
    if (bytes == null) return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameFile = 'story_$timestamp.jpg';

    if (ref.read(webPlatformProvider)) {
      return XFile.fromData(bytes, name: nameFile, mimeType: 'image/jpeg');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$nameFile');
    await file.writeAsBytes(bytes);

    return XFile(file.path);
  }
}

@riverpod
Future<File?> getCroppedImageFromPicker(
  Ref ref,
  Stream<InstaAssetsExportDetails> cropStream,
) async {
  File? file;
  await for (final event in cropStream) {
    if (event.data.isNotEmpty) {
      file = event.data.firstOrNull?.croppedFile;
    }
  }
  return file;
}

@riverpod
class StoriesNotifier extends _$StoriesNotifier with LogMixin {
  static const int _pageSize = 10;

  ListRepository get _repository => ref.read(listRepositoryProvider);
  @override
  StoriesState build() => StoriesState.initial();

  Future<void> fetchStories() async {
    log.info('Fetching stories list');
    state = StoriesState(state: StoriesConcreteState.loading);
    final result = await _repository.getListStories(page: 1, size: _pageSize);
    result.fold(
      (failure) {
        log.warning('Failed to fetch stories: ${failure.message}');
        state = state.copyWith(
          state: StoriesConcreteState.failure,
          message: failure.message,
        );
      },
      (stories) {
        log.info('Successfully fetched ${stories.length} stories');
        state = state.copyWith(
          state: StoriesConcreteState.loaded,
          stories: stories,
          page: 1,
          hasReachedEnd: stories.length < _pageSize,
        );
      },
    );
  }

  Future<void> fetchMoreStories() async {
    // Guard: don't fetch if already loading, loading more, or reached end
    if (state.state == StoriesConcreteState.loading ||
        state.state == StoriesConcreteState.loadingMore ||
        state.hasReachedEnd) {
      return;
    }

    final nextPage = state.page + 1;
    log.info('Fetching more stories (page $nextPage)');
    state = state.copyWith(state: StoriesConcreteState.loadingMore);

    final result = await _repository.getListStories(
      page: nextPage,
      size: _pageSize,
    );
    result.fold(
      (failure) {
        log.warning('Failed to fetch more stories: ${failure.message}');
        // Revert to loaded state on failure, keep existing stories
        state = state.copyWith(
          state: StoriesConcreteState.loaded,
          message: failure.message,
        );
      },
      (newStories) {
        log.info('Successfully fetched ${newStories.length} more stories');
        state = state.copyWith(
          state: StoriesConcreteState.loaded,
          stories: [...state.stories, ...newStories],
          page: nextPage,
          hasReachedEnd: newStories.length < _pageSize,
        );
      },
    );
  }

  void resetState() {
    state = StoriesState.initial();
  }
}

class MockImageFile extends _$ImageFile with Mock implements ImageFile {}

class MockStories extends _$StoriesNotifier
    with Mock
    implements StoriesNotifier {
  @override
  StoriesState build() => StoriesState.initial();

  void setState(StoriesState newState) => state = newState;
}

@Riverpod()
class AddStoryNotifier extends _$AddStoryNotifier with LogMixin {
  AddStoryRepository get _repository => ref.read(addStoryRepositoryProvider);
  @override
  AddStoryState build() {
    return const AddStoryInitial();
  }

  Future<void> addStory({
    required String description,
    required XFile photoFile,
    double? lat,
    double? lon,
  }) async {
    log.info('Adding story: $description');
    state = const AddStoryLoading();
    final result = await _repository.addStory(
      description,
      photoFile,
      lat: lat,
      lon: lon,
    );

    // Check if the provider is still mounted before updating state
    if (!ref.mounted) return;

    result.fold(
      (failure) {
        log.warning('Failed to add story: ${failure.message}');
        state = AddStoryFailure(failure);
      },
      (story) {
        log.info('Successfully added story');
        state = const AddStorySuccess();
      },
    );
  }

  void resetState() {
    state = const AddStoryInitial();
  }
}
