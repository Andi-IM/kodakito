import 'dart:io';

import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/home/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/home/view_model/stories_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

/// Provider for managing selected location for story
@riverpod
class SelectedLocation extends _$SelectedLocation with LogMixin {
  @override
  PlaceInfo? build() => null;

  void setLocation(PlaceInfo? location) {
    log.info('Setting location: ${location?.city}, ${location?.country}');
    state = location;
  }

  void clear() {
    log.info('Clearing selected location');
    state = null;
  }
}

/// Provider for managing selected photo file for story
@riverpod
class SelectedPhotoFile extends _$SelectedPhotoFile with LogMixin {
  @override
  XFile? build() => null;

  void setFile(XFile file) {
    log.info('Setting photo file: ${file.name}');
    state = file;
  }

  void clear() {
    log.info('Clearing selected photo file');
    state = null;
  }
}

@riverpod
class ImageFile extends _$ImageFile with LogMixin {
  @override
  Uint8List? build() {
    return null;
  }

  void setImageFile(Uint8List imageFile) {
    log.info('Setting image file: ${imageFile.length} bytes');
    state = imageFile;
  }

  Future<XFile?> toFile() async {
    final bytes = state;
    if (bytes == null) {
      log.warning('Cannot convert to file: no image data');
      return null;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameFile = 'story_$timestamp.jpg';
    log.info('Converting image to file: $nameFile');

    if (ref.read(webPlatformProvider)) {
      log.info('Creating XFile from data (web platform)');
      return XFile.fromData(bytes, name: nameFile, mimeType: 'image/jpeg');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$nameFile');
    await file.writeAsBytes(bytes);
    log.info('Created file at: ${file.path}');

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
  ListRepository get _repository => ref.read(listRepositoryProvider);
  @override
  StoriesState build() => StoriesState.initial();

  Future<void> getStories() async {
    if (state.isInitialLoading || state.isLoadingMore) return;

    if (state.nextPage == null) return;

    try {
      if (state.nextPage == 1) {
        state = state.copyWith(isInitialLoading: true, hasError: false);
      } else {
        state = state.copyWith(isLoadingMore: true, hasError: false);
      }

      final result = await _repository.getListStories(
        page: state.nextPage!,
        size: state.sizeItems,
      );

      result.fold(
        (failure) {
          log.warning('Failed to fetch stories: ${failure.message}');
          state = state.copyWith(
            hasError: true,
            errorMessage: failure.message,
            isInitialLoading: false,
            isLoadingMore: false,
          );
        },
        (stories) {
          log.info('Successfully fetched ${stories.length} stories');
          final allStories = [...state.stories, ...stories];
          final nextPage = stories.length < state.sizeItems
              ? null
              : state.nextPage! + 1;

          state = state.copyWith(
            stories: allStories,
            nextPage: nextPage,
            isInitialLoading: false,
            isLoadingMore: false,
            hasError: false,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      log.warning('Failed to fetch stories: $e');
      state = state.copyWith(
        hasError: true,
        errorMessage: e.toString(),
        isInitialLoading: false,
        isLoadingMore: false,
      );
    }
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
