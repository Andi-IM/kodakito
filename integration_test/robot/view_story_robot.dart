import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/main/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ViewStoryRobot {
  final WidgetTester tester;

  const ViewStoryRobot(this.tester);

  final loadingIndicatorKey = const ValueKey('loadingIndicator');

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pump();
  }

  void verifyPageIsLoading() {
    final loadingFinder = find.byKey(loadingIndicatorKey);
    expect(loadingFinder, findsOneWidget);
  }

  Future<void> verifyStoryCardIsDisplayed() async {
    await tester.pumpAndSettle();
    final storyCardFinder = find.byType(StoryCard);
    expect(storyCardFinder, findsNWidgets(10));
  }

  Future<Story> tapStoryCard(int index) async {
    final storyCardFinder = find.byType(StoryCard).at(index);
    final story = (tester.widget(storyCardFinder) as StoryCard).story;
    await tester.tap(storyCardFinder);
    await tester.pumpAndSettle();
    return story;
  }

  Future<void> verifyStoryDetailIsDisplayedWithStory(Story story) async {
    final titleFinder = find.text(story.name);
    expect(titleFinder, findsOneWidget);
    final descriptionFinder = find.text(story.description);
    expect(descriptionFinder, findsOneWidget);
    final imageFinder = find.byKey(ValueKey('image_${story.id}'));
    expect(imageFinder, findsOneWidget);
  }
}
