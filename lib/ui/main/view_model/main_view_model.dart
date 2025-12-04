import 'dart:io';
import 'dart:typed_data';

import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
}

@riverpod
class StoriesNotifier extends _$StoriesNotifier with LogMixin {
  ListRepository get _repository => ref.read(listRepositoryProvider);
  @override
  StoriesState build() {
    return const StoriesState.initial();
  }

  Future<void> fetchStories() async {
    log.info('Fetching stories list');
    state = state.copyWith(state: StoriesConcreteState.loading);
    final result = await _repository.getListStories();
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
        );
      },
    );
  }

  void resetState() {
    state = const StoriesState.initial();
  }
}

class MockImageFile extends _$ImageFile with Mock implements ImageFile {}

class MockStories extends _$StoriesNotifier
    with Mock
    implements StoriesNotifier {}

@riverpod
Future<String?> version(Ref ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}

@Riverpod()
class AddStoryNotifier extends _$AddStoryNotifier with LogMixin {
  AddStoryRepository get _repository => ref.read(addStoryRepositoryProvider);
  @override
  AddStoryState build() {
    return const AddStoryState.initial();
  }

  Future<void> addStory({
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    log.info('Adding story: $description');
    state = AddStoryState.loading();
    final result = await _repository.addStory(
      description,
      photo,
      lat: lat,
      lon: lon,
    );
    result.fold(
      (failure) {
        log.warning('Failed to add story: ${failure.message}');
        state = AddStoryState.failure(failure);
      },
      (story) {
        log.info('Successfully added story');
        state = AddStoryState.success();
      },
    );
  }

  void resetState() {
    state = const AddStoryState.initial();
  }
}
