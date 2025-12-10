import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/ui/detail/widgets/free/story_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:window_size_classes/window_size_classes.dart';

class FakeDetailScreenContent extends DetailScreenContent {
  final StoryState initialState;
  FakeDetailScreenContent(this.initialState);

  @override
  StoryState build(String id) {
    return initialState;
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final mockStory = Story(
    id: 'story-1',
    name: 'Story 1',
    description: 'Description 1',
    photoUrl: 'https://example.com/photo.jpg',
    createdAt: DateTime.now(),
    lat: 0.0,
    lon: 0.0,
  );

  testWidgets(
    'StoryDetailPage displays loading indicator when state is Loading',
    (tester) async {
      await mockNetworkImages(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailScreenContentProvider(
                'story-1',
              ).overrideWith(() => FakeDetailScreenContent(const Loading())),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StoryDetailPage(id: 'story-1'),
            ),
          ),
        );
      });

      expect(find.byType(LoadingIndicatorM3E), findsOneWidget);
    },
  );

  testWidgets('StoryDetailPage displays error message when state is Error', (
    tester,
  ) async {
    const errorMessage = 'Failed to load story';
    await mockNetworkImages(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                const Error(errorMessage: errorMessage),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );
    });

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('WindowWidthClass works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final _ = WindowWidthClass.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('StoryDetailPage displays story content when Loaded', (
    tester,
  ) async {
    final customColorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

    // Force compact layout
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await mockNetworkImages(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                Loaded(story: mockStory, imageBytes: null),
              ),
            ),
            storyColorSchemeProvider(null).overrideWith(
              (ref) => Future.value(
                customColorScheme,
              ), // Returning proper scheme again
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
    });

    expect(find.text('Story Detail'), findsOneWidget);
    expect(find.text('Story 1'), findsOneWidget);
    expect(find.text('Description 1'), findsOneWidget);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedTheme &&
            widget.duration == const Duration(milliseconds: 500),
      ),
      findsOneWidget,
    );
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });
  testWidgets('StoryDetailPage displays medium layout on wide screen', (
    tester,
  ) async {
    final customColorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

    // Force wide layout
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await mockNetworkImages(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider('story-1').overrideWith(
              () => FakeDetailScreenContent(
                Loaded(story: mockStory, imageBytes: null),
              ),
            ),
            storyColorSchemeProvider(
              null,
            ).overrideWith((ref) => Future.value(customColorScheme)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
    });

    expect(find.byKey(const ValueKey("MediumLayout")), findsOneWidget);
    expect(find.byKey(const ValueKey("CompactLayout")), findsNothing);
  });
}
