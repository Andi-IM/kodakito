import 'package:dicoding_story/ui/auth/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthButton Widget Test', () {
    testWidgets('renders label correctly', (WidgetTester tester) async {
      const label = 'Login';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthButton(label: label, onPressed: () {}),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool isPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthButton(
              label: 'Login',
              onPressed: () {
                isPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthButton));
      await tester.pump();

      expect(isPressed, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthButton(label: 'Login', onPressed: () {}, isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('does not call onPressed when tapped while loading', (
      WidgetTester tester,
    ) async {
      bool isPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthButton(
              label: 'Login',
              onPressed: () {
                isPressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AuthButton));
      await tester.pump();

      expect(isPressed, isFalse);
    });
  });
}
