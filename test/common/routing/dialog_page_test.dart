import 'package:dicoding_story/common/routing/dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DialogPage', () {
    test('can be instantiated with required parameters', () {
      final dialogPage = DialogPage(builder: (context) => const SizedBox());

      expect(dialogPage, isA<DialogPage>());
      expect(dialogPage.barrierDismissible, isFalse);
      expect(dialogPage.barrierColor, equals(Colors.black54));
      expect(dialogPage.useSafeArea, isTrue);
    });

    test('can be instantiated with all parameters', () {
      final dialogPage = DialogPage(
        key: const ValueKey('test-dialog'),
        name: 'test',
        arguments: {'key': 'value'},
        restorationId: 'test-restoration-id',
        anchorPoint: const Offset(10, 20),
        barrierColor: Colors.red,
        barrierDismissible: true,
        barrierLabel: 'Close dialog',
        useSafeArea: false,
        builder: (context) => const Text('Dialog Content'),
      );

      expect(dialogPage.barrierDismissible, isTrue);
      expect(dialogPage.barrierColor, equals(Colors.red));
      expect(dialogPage.useSafeArea, isFalse);
      expect(dialogPage.barrierLabel, equals('Close dialog'));
      expect(dialogPage.anchorPoint, equals(const Offset(10, 20)));
    });

    testWidgets('createRoute returns a DialogRoute', (tester) async {
      final dialogPage = DialogPage(
        builder: (context) => const Text('Dialog Content'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = dialogPage.createRoute(context);
              expect(route, isA<DialogRoute>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('createRoute creates route with correct settings', (
      tester,
    ) async {
      final dialogPage = DialogPage(
        name: 'test-dialog',
        barrierDismissible: true,
        barrierColor: Colors.blue,
        builder: (context) => const Text('Dialog Content'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final route = dialogPage.createRoute(context) as DialogRoute;
              expect(route.settings, equals(dialogPage));
              expect(route.barrierDismissible, isTrue);
              expect(route.barrierColor, equals(Colors.blue));
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
