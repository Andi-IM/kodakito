import 'package:dicoding_story/data/model/story.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'detail_provider.g.dart';

final Story _story = Story(
  id: '1',
  name: 'Dimas',
  description:
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
  photoUrl: 'https://picsum.photos/id/237/400/200',
  createdAt: DateTime.now(),
);

@Riverpod()
class DetailScreenContent extends _$DetailScreenContent {
  @override
  Story build() {
    return _story;
  }
}
