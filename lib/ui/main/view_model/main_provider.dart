import 'dart:typed_data';

import 'package:dicoding_story/data/repositories/list/list_repository.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
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
class StoriesNotifier extends _$StoriesNotifier {
  ListRepository get _repository => ref.read(listRepositoryProvider);
  @override
  StoriesState build() {
    // Initialization and fetching
    Future.microtask(() => fetchStories());
    return const StoriesState.initial();
  }

  bool get isFetching => state.state != StoriesConcreteState.loading;

  Future<void> fetchStories() async {
    state = state.copyWith(state: StoriesConcreteState.loading);
    final result = await _repository.getListStories();
    result.fold(
      (failure) => state = state.copyWith(
        state: StoriesConcreteState.failure,
        message: failure.message,
      ),
      (stories) {
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
