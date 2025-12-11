import 'package:dicoding_story/domain/models/story/story.dart';
import 'dart:typed_data' show Uint8List;

import 'package:latlong_to_place/latlong_to_place.dart';

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
  final Uint8List? imageBytes;
  final PlaceInfo? location;
  const Loaded({required this.story, required this.imageBytes, this.location});
}

class Error extends StoryState {
  final String errorMessage;
  const Error({required this.errorMessage});
}
