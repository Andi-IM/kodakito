import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:equatable/equatable.dart';

enum StoriesConcreteState { initial, loading, loaded, loadingMore, failure }

class StoriesState extends Equatable {
  final StoriesConcreteState state;
  final List<Story> stories;
  final String? message;
  final int page;
  final bool hasReachedEnd;

  const StoriesState({
    required this.state,
    this.stories = const [],
    this.message,
    this.page = 1,
    this.hasReachedEnd = false,
  });

  const StoriesState.initial() : this(state: StoriesConcreteState.initial);

  bool get isLoadingMore => state == StoriesConcreteState.loadingMore;

  StoriesState copyWith({
    StoriesConcreteState? state,
    List<Story>? stories,
    String? message,
    int? page,
    bool? hasReachedEnd,
  }) {
    return StoriesState(
      state: state ?? this.state,
      stories: stories ?? this.stories,
      message: message ?? this.message,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  T when<T>({
    required T Function(List<Story> stories) data,
    required T Function() loading,
    required T Function(Object error, StackTrace? stackTrace) error,
  }) {
    switch (state) {
      case StoriesConcreteState.initial:
      case StoriesConcreteState.loading:
        return loading();
      case StoriesConcreteState.loaded:
      case StoriesConcreteState.loadingMore:
        return data(stories);
      case StoriesConcreteState.failure:
        return error(message ?? 'Unknown error', null);
    }
  }

  @override
  String toString() {
    return 'StoriesState(state: $state, stories: $stories, message: $message, page: $page, hasReachedEnd: $hasReachedEnd)';
  }

  @override
  List<Object?> get props => [state, stories, message, page, hasReachedEnd];
}
