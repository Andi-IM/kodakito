import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/l10n/app_localizations.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  final tStory = Story(
    id: 'story-1',
    name: 'Test Story',
    description: 'This is a test story description',
    photoUrl: 'https://example.com/photo.jpg',
    createdAt: DateTime(2022, 1, 1),
    lat: 0.0,
    lon: 0.0,
  );

  group('StoryDetailPage', () {
    testWidgets('shows loading indicator when state is loading', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockDetailContent();
      when(
        () => mockNotifier.build('story-1'),
      ).thenReturn(const StoryState.initial());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider.overrideWith(() => mockNotifier),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is error', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockDetailContent();
      when(() => mockNotifier.build('story-1')).thenReturn(
        const StoryState(
          state: StoryStateType.error,
          errorMessage: 'Network Error',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider.overrideWith(() => mockNotifier),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      expect(find.text('Network Error'), findsOneWidget);
    });

    testWidgets('shows unknown error when state is error without message', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockDetailContent();
      when(
        () => mockNotifier.build('story-1'),
      ).thenReturn(const StoryState(state: StoryStateType.error));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider.overrideWith(() => mockNotifier),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      expect(find.text('Unknown Error'), findsOneWidget);
    });

    testWidgets('shows no data message when story is null', (
      WidgetTester tester,
    ) async {
      final mockNotifier = MockDetailContent();
      when(
        () => mockNotifier.build('story-1'),
      ).thenReturn(const StoryState(state: StoryStateType.loaded));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider.overrideWith(() => mockNotifier),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('displays story details when state is loaded', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        final mockNotifier = MockDetailContent();
        when(
          () => mockNotifier.build('story-1'),
        ).thenReturn(StoryState(state: StoryStateType.loaded, story: tStory));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailScreenContentProvider.overrideWith(() => mockNotifier),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StoryDetailPage(id: 'story-1'),
            ),
          ),
        );

        // Verify story name is displayed
        expect(find.text('Test Story'), findsOneWidget);

        // Verify story description is displayed
        expect(find.text('This is a test story description'), findsOneWidget);

        // Verify date is displayed
        expect(find.text('2022-01-01'), findsOneWidget);

        // Verify avatar with first letter
        expect(find.text('T'), findsWidgets);

        // Verify Image.network is present
        expect(find.byType(Image), findsWidgets);
      });
    });

    testWidgets('displays error icon when image fails to load', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        final mockNotifier = MockDetailContent();
        when(
          () => mockNotifier.build('story-1'),
        ).thenReturn(StoryState(state: StoryStateType.loaded, story: tStory));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailScreenContentProvider.overrideWith(() => mockNotifier),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StoryDetailPage(id: 'story-1'),
            ),
          ),
        );

        // Find the Image widget
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsWidgets);

        final imageWidget = tester.widget<Image>(imageFinder.first);

        // Manually invoke errorBuilder
        final errorWidget = imageWidget.errorBuilder!(
          tester.element(imageFinder.first),
          'error',
          StackTrace.empty,
        );

        // Pump the error widget to verify its content
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: errorWidget)));

        expect(find.byIcon(Icons.broken_image), findsOneWidget);
      });
    });

    testWidgets('has app bar with title', (WidgetTester tester) async {
      final mockNotifier = MockDetailContent();
      when(
        () => mockNotifier.build('story-1'),
      ).thenReturn(const StoryState(state: StoryStateType.loading));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            detailScreenContentProvider.overrideWith(() => mockNotifier),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StoryDetailPage(id: 'story-1'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders compact layout for compact width', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        // Set a narrow screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));

        final mockNotifier = MockDetailContent();
        when(
          () => mockNotifier.build('story-1'),
        ).thenReturn(StoryState(state: StoryStateType.loaded, story: tStory));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailScreenContentProvider.overrideWith(() => mockNotifier),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StoryDetailPage(id: 'story-1'),
            ),
          ),
        );

        // Verify the content is scrollable
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Restore screen size
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('renders medium/extended layout for wide screen', (
      WidgetTester tester,
    ) async {
      await mockNetworkImages(() async {
        // Set a wide screen size
        await tester.binding.setSurfaceSize(const Size(1200, 800));

        final mockNotifier = MockDetailContent();
        when(
          () => mockNotifier.build('story-1'),
        ).thenReturn(StoryState(state: StoryStateType.loaded, story: tStory));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              detailScreenContentProvider.overrideWith(() => mockNotifier),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: StoryDetailPage(id: 'story-1'),
            ),
          ),
        );

        // Verify the content is scrollable
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Restore screen size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
