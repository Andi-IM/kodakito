import 'package:dicoding_story/ui/auth/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogoWidget Tests', () {
    testWidgets('renders light logo in light mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: LogoWidget(maxWidth: 200)),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/logo_light.png');
    });

    testWidgets('renders dark logo in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: LogoWidget(maxWidth: 200)),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/logo_dark.png');
    });

    testWidgets('respects maxWidth constraint', (WidgetTester tester) async {
      const double maxWidth = 150.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: LogoWidget(maxWidth: maxWidth)),
        ),
      );

      final logoFinder = find.byType(LogoWidget);
      final constrainedBoxFinder = find.descendant(
        of: logoFinder,
        matching: find.byType(ConstrainedBox),
      );

      expect(constrainedBoxFinder, findsOneWidget);

      final ConstrainedBox constrainedBox = tester.widget(constrainedBoxFinder);
      expect(constrainedBox.constraints.maxWidth, maxWidth);
    });
  });
}
