import 'package:dicoding_story/data/model/story.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'main_provider.g.dart';

@Riverpod()
class NavigationData extends _$NavigationData {
  @override
  NavigationRailM3EType build() {
    return NavigationRailM3EType.expanded;
  }

  void toggleNavigationRail(NavigationRailM3EType type) => state = type;
}

final List<Story> _dummyStories = [
  Story(
    id: '1',
    name: 'Dimas',
    description:
        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
    photoUrl: 'https://picsum.photos/id/237/400/200',
    createdAt: DateTime.now(),
  ),
  Story(
    id: '2',
    name: 'Arif',
    description:
        'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
    photoUrl: 'https://picsum.photos/id/238/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Story(
    id: '3',
    name: 'Fikri',
    description:
        'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.',
    photoUrl: 'https://picsum.photos/id/239/400/200',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

@Riverpod()
class MainScreenContent extends _$MainScreenContent {
  @override
  List<Story> build() {
    return _dummyStories;
  }
}
