import 'dart:typed_data';

import 'package:dicoding_story/data/model/story.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'main_provider.g.dart';

@Riverpod()
class ImageFile extends _$ImageFile {
  @override
  Uint8List? build() {
    return null;
  }

  void setImageFile(Uint8List imageFile) {
    state = imageFile;
  }
}

@Riverpod()
class MainScreenContent extends _$MainScreenContent {
  @override
  List<Story> build() {
    return dummyStories;
  }
}
