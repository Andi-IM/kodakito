import 'package:dicoding_story/domain/models/story/story.dart';

sealed class StoryState {
  const StoryState();
}

class Initial extends StoryState {
  const Initial();
}

class Loading extends StoryState {
  const Loading();
}

class Loaded extends StoryState {
  final Story story;
  const Loaded({required this.story});
}

class Error extends StoryState {
  final String errorMessage;
  const Error({required this.errorMessage});
}
