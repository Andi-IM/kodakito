import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stories_state.freezed.dart';

@freezed
abstract class StoriesState with _$StoriesState {
  const factory StoriesState({
    required List<Story> stories,
    required bool isInitialLoading,
    required bool isLoadingMore,
    required bool hasError,
    required String? errorMessage,
    required int? nextPage,
    required int sizeItems,
  }) = _StoriesState;

  factory StoriesState.initial() => const StoriesState(
    stories: [],
    nextPage: 1,
    sizeItems: 10,
    isInitialLoading: false,
    isLoadingMore: false,
    hasError: false,
    errorMessage: null,
  );
}
