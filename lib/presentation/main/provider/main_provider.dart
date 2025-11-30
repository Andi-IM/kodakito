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



@Riverpod()
class MainScreenContent extends _$MainScreenContent {
  @override
  List<Story> build() {
    return dummyStories;
  }
}
