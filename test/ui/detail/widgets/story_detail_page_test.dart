import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/l10n/app_localizations.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('StoryDetailPage', () {
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
  });
}
