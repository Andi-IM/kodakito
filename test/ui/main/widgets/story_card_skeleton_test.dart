import 'package:dicoding_story/ui/main/widgets/story_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('StoryCardSkeleton', () {
    testWidgets('renders correctly with all skeleton elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StoryCardSkeleton())),
      );

      // Verify Card is rendered
      expect(find.byType(Card), findsOneWidget);

      // Verify Shimmer effect is applied
      expect(find.byType(Shimmer), findsOneWidget);

      // Verify AspectRatio for image placeholder
      expect(find.byType(AspectRatio), findsOneWidget);
      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, 16 / 9);
    });

    testWidgets('has correct card margins and shape', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StoryCardSkeleton())),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(
        card.margin,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
      expect(card.clipBehavior, Clip.antiAlias);
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('uses theme colors for shimmer effect', (
      WidgetTester tester,
    ) async {
      final customTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: const Scaffold(body: StoryCardSkeleton()),
        ),
      );

      final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
      expect(
        shimmer.gradient.colors.first,
        customTheme.colorScheme.surfaceContainerHighest,
      );
    });

    testWidgets('contains placeholder containers for content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StoryCardSkeleton())),
      );

      // Find all Containers (placeholders for image, name, description, date)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Verify there are multiple placeholder containers
      // At least: 1 image + 1 name + 2 description lines + 2 date elements = 6
      expect(tester.widgetList(containers).length, greaterThanOrEqualTo(6));
    });

    testWidgets('renders in dark theme without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: StoryCardSkeleton()),
        ),
      );

      expect(find.byType(StoryCardSkeleton), findsOneWidget);
      expect(find.byType(Shimmer), findsOneWidget);
    });
  });
}
