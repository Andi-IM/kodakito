import 'dart:typed_data';

import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_provider.g.dart';

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
Future<String?> fetchUserData(Ref ref) async {
  final cache = ref.read(cacheRepositoryProvider);
  final result = await cache.getToken();
  return result.fold((l) => null, (r) => r.userName);
}

@riverpod
class StoriesNotifier extends _$StoriesNotifier with LogMixin {
  ListRepository get _repository => ref.read(listRepositoryProvider);
  @override
  StoriesState build() {
    // Initialization and fetching
    Future.microtask(() => fetchStories());
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
