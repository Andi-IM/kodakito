import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_provider.g.dart';

@Riverpod()
class DetailScreenContent extends _$DetailScreenContent {
  @override
  Story build(int id) {
    return Story(
      id: id.toString(),
      name: '',
      description: '',
      photoUrl: '',
      createdAt: DateTime.now(),
      lat: 0,
      lon: 0,
    );
  }
}
