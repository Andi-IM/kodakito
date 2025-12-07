import 'package:cached_network_image/cached_network_image.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_medium_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  testWidgets('story detail medium layout renders correctly', (tester) async {
    final story = Story(
      id: 'id-test1',
      name: 'Andi Irham',
      photoUrl: 'https://picsum.photos/200/300',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      createdAt: DateTime(2022, 1, 1),
      lat: null,
      lon: null,
    );

    await mockNetworkImages(() async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: StoryDetailMediumLayout(story: story)),
        ),
      );
    });

    // Verify widgets exist
    expect(find.byType(StoryDetailMediumLayout), findsOneWidget);
    expect(find.text('Andi Irham'), findsOneWidget);
    expect(
      find.text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      ),
      findsOneWidget,
    );
    // Verify date is displayed in localized format (yMMMd)
    expect(find.text('Jan 1, 2022'), findsOneWidget);

    // Verify Hero
    expect(find.byType(Hero), findsOneWidget);
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'id-test1');

    final cachedImage = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(cachedImage.cacheKey, 'storyDetailKey_id-test1');
  });
}
