import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_view_model.g.dart';

@Riverpod()
class DetailScreenContent extends _$DetailScreenContent with LogMixin {
  DetailRepository get _repository => ref.read(detailRepositoryProvider);

  @override
  StoryState build(String id) {
    Future.microtask(() => fetchDetailStory(id));
    return const StoryState.initial();
  }

  Future<void> fetchDetailStory(String id) async {
    log.info('Fetching detail for story: $id');
    state = state.copyWith(state: StoryStateType.loading);
    final result = await _repository.getDetailStory(id);
    result.fold(
      (failure) {
        log.warning('Failed to fetch story detail: ${failure.message}');
        state = state.copyWith(
          state: StoryStateType.error,
          errorMessage: failure.message,
        );
      },
      (story) {
        log.info('Successfully fetched story detail');
        state = state.copyWith(state: StoryStateType.loaded, story: story);
      },
    );
  }

  void resetState() {
    state = const StoryState.initial();
  }
}
