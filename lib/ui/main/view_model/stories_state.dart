import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:equatable/equatable.dart';

enum StoriesConcreteState { initial, loading, loaded, failure }

class StoriesState extends Equatable {
  final StoriesConcreteState state;
  final List<Story> stories;
  final String? message;

  const StoriesState({
    required this.state,
    this.stories = const [],
    this.message,
  });

  const StoriesState.initial() : this(state: StoriesConcreteState.initial);

  StoriesState copyWith({
    StoriesConcreteState? state,
    List<Story>? stories,
    String? message,
  }) {
    return StoriesState(
      state: state ?? this.state,
      stories: stories ?? this.stories,
      message: message ?? this.message,
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
        return data(stories);
      case StoriesConcreteState.failure:
        return error(message ?? 'Unknown error', null);
    }
  }

  @override
  String toString() {
    return 'StoriesState(state: $state, stories: $stories, message: $message)';
  }

  @override
  List<Object?> get props => [state, stories, message];
}
