import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({required Widget child}) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: child,
          ),
        ),
      ),
    );
  }

  group('NameWidget', () {
    testWidgets('renders correctly', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: NameWidget(controller: controller, isLoading: false),
        ),
      );

      expect(find.byType(NameWidget), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows error message when name is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: NameWidget(controller: controller, isLoading: false),
        ),
      );

      final nameField = find.byKey(const ValueKey('nameField'));

      // Enter text and clear it to trigger validation
      await tester.enterText(nameField, 'a');
      await tester.pump();
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Expect error message from Validators.required
      expect(find.text('This field cannot be empty'), findsOneWidget);
    });
  });

  group('EmailWidget', () {
    testWidgets('renders correctly', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: EmailWidget(controller: controller, isLoading: false),
        ),
      );

      expect(find.byType(EmailWidget), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows error message when email is invalid', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: EmailWidget(controller: controller, isLoading: false),
        ),
      );

      final emailField = find.byKey(const ValueKey('emailField'));

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      // Expect error message
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error message when email is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: EmailWidget(controller: controller, isLoading: false),
        ),
      );

      final emailField = find.byKey(const ValueKey('emailField'));

      // Enter empty text to trigger validation.
      // Since it starts empty, enter 'a' then clear it to force interaction.
      await tester.enterText(emailField, 'a');
      await tester.pump();
      await tester.enterText(emailField, '');
      await tester.pumpAndSettle();

      // Expect error message
      expect(find.text('This field cannot be empty'), findsOneWidget);
    });

    testWidgets('shows no error when email is valid', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: EmailWidget(controller: controller, isLoading: false),
        ),
      );

      final emailField = find.byKey(const ValueKey('emailField'));

      // Enter valid email
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Expect no error message
      expect(find.text('Please enter a valid email address'), findsNothing);
    });
  });

  group('PasswordWidget', () {
    testWidgets('renders correctly', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: PasswordWidget(controller: controller, isLoading: false),
        ),
      );

      expect(find.byType(PasswordWidget), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows error message when password is too short', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: PasswordWidget(controller: controller, isLoading: false),
        ),
      );

      final passwordField = find.byKey(const ValueKey('passwordField'));

      // Enter short password
      await tester.enterText(passwordField, '12345');
      await tester.pumpAndSettle();

      // Expect error message
      expect(
        find.text('Password must be at least 8 characters long'),
        findsOneWidget,
      );
    });

    testWidgets('shows error message when password is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: PasswordWidget(controller: controller, isLoading: false),
        ),
      );

      final passwordField = find.byKey(const ValueKey('passwordField'));

      // Enter empty text. Enter 'a' then clear to force validation.
      await tester.enterText(passwordField, 'a');
      await tester.pump();
      await tester.enterText(passwordField, '');
      await tester.pumpAndSettle();

      // Expect error message
      expect(find.text('This field cannot be empty'), findsOneWidget);
    });

    testWidgets('shows no error when password is valid', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: PasswordWidget(controller: controller, isLoading: false),
        ),
      );

      final passwordField = find.byKey(const ValueKey('passwordField'));

      // Enter valid password
      await tester.enterText(passwordField, '12345678');
      await tester.pumpAndSettle();

      // Expect no error message
      expect(
        find.text('Password must be at least 8 characters long'),
        findsNothing,
      );
    });

    testWidgets('toggles password visibility', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: PasswordWidget(controller: controller, isLoading: false),
        ),
      );

      // Initial state: obscureText is true (default)
      final textFieldFinder = find.byType(TextField);
      expect(tester.widget<TextField>(textFieldFinder).obscureText, true);

      // Find visibility toggle icon
      final toggleButton = find.byIcon(Icons.visibility_outlined);
      expect(toggleButton, findsOneWidget);

      // Tap to toggle
      await tester.tap(toggleButton);
      await tester.pump(); // Pump once to handle tap
      await tester.pump(); // Pump again for provider update if needed

      // Verify icon changed (implies state changed)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Verify obscured is false
      // Verify obscured is false
      expect(tester.widget<TextField>(textFieldFinder).obscureText, false);
    });
  });
}
