import 'dart:typed_data';

import 'package:dicoding_story/data/services/api/model/story.dart';
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
Future<List<Story>> mainScreenContent(Ref ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return dummyStories;
}
