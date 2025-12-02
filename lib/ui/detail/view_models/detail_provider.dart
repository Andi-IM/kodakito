import 'package:dicoding_story/data/repositories/detail/detail_repository.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_provider.g.dart';

@Riverpod()
class DetailScreenContent extends _$DetailScreenContent {
  DetailRepository get _repository => ref.read(detailRepositoryProvider);
  
  @override
  StoryState build(String id) {
    Future.microtask(() => fetchDetailStory(id));
    return const StoryState.initial();
  }

  bool get isFetching => state.state == StoryStateType.loading;

  Future<void> fetchDetailStory(String id) async {
    state = state.copyWith(state: StoryStateType.loading);
    final result = await _repository.getDetailStory(id);
    result.fold(
      (failure) => state = state.copyWith(
        state: StoryStateType.error,
        errorMessage: failure.message,
      ),
      (story) {
        state = state.copyWith(state: StoryStateType.loaded, story: story);
      },
    );
  }

  void resetState() {
    state = const StoryState.initial();
  }
}
