import 'package:dicoding_story/data/model/story.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'detail_provider.g.dart';

@Riverpod()
class DetailScreenContent extends _$DetailScreenContent {
  @override
  Story build(int id) {
    return dummyStories.where((element) => element.id == id.toString()).first;
  }
}
