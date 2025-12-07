import 'package:cached_network_image/cached_network_image.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/main/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  group('StoryCard', () {
    final tStory = Story(
      id: 'story-1',
      name: 'Story Name',
      description: 'Story Description',
      photoUrl: 'https://example.com/photo.jpg',
      createdAt: DateTime(2022, 1, 1),
      lat: 0,
      lon: 0,
    );

    testWidgets('renders correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: StoryCard(story: tStory)),
          ),
        );
      });

      // Verify name and description are displayed
      expect(find.text('Story Name'), findsOneWidget);
      expect(find.text('Story Description'), findsOneWidget);

      // Verify date is displayed (formatted as Jan 1, 2022)
      expect(find.text('Jan 1, 2022'), findsOneWidget);

      // Verify CachedNetworkImage is present
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool isTapped = false;

      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: StoryCard(
                story: tStory,
                onTap: () {
                  isTapped = true;
                },
              ),
            ),
          ),
        );
      });

      // Tap the card
      await tester.tap(find.byType(StoryCard));
      await tester.pump();

      // Verify callback was called
      expect(isTapped, isTrue);
    });

    testWidgets('shows error widget when image fails to load', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: StoryCard(story: tStory)),
          ),
        );
      });

      final cachedImageFinder = find.byType(CachedNetworkImage);
      expect(cachedImageFinder, findsOneWidget);
      final cachedImage = tester.widget<CachedNetworkImage>(cachedImageFinder);

      // Manually invoke errorWidget
      final errorWidget = cachedImage.errorWidget!(
        tester.element(cachedImageFinder),
        'url',
        'error',
      );

      // Pump the error widget to verify its content
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorWidget)));
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('shows loading indicator when image is loading', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: StoryCard(story: tStory)),
          ),
        );
      });

      final cachedImageFinder = find.byType(CachedNetworkImage);
      expect(cachedImageFinder, findsOneWidget);
      final cachedImage = tester.widget<CachedNetworkImage>(cachedImageFinder);

      // Manually invoke progressIndicatorBuilder
      final progressWidget = cachedImage.progressIndicatorBuilder!(
        tester.element(cachedImageFinder),
        'url',
        DownloadProgress('url', 100, 50), // 50% progress
      );

      // Pump the progress widget to verify its content
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: progressWidget)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });
  });
}
