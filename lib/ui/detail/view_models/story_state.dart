import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:equatable/equatable.dart';

enum StoryStateType { initial, loading, loaded, error }

class StoryState extends Equatable {
  const StoryState({required this.state, this.story, this.errorMessage});

  final Story? story;
  final StoryStateType state;
  final String? errorMessage;

  const StoryState.initial()
    : this(state: StoryStateType.initial, errorMessage: null);

  StoryState copyWith({
    StoryStateType? state,
    Story? story,
    String? errorMessage,
  }) {
    return StoryState(
      state: state ?? this.state,
      story: story ?? this.story,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'StoryState(story: $story, state: $state, errorMessage: $errorMessage)';
  }

  @override
  List<Object?> get props => [story, state, errorMessage];
}
