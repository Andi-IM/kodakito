import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/app/observer.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_button.dart';
import 'package:dicoding_story/ui/auth/widgets/login_page.dart';
import 'package:dicoding_story/ui/auth/widgets/register_page.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/ui/main/widgets/settings_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// This Integration Test launches the app with the local configuration
/// Make sure to set the environment variable to 'development' before running this test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test with local data', () {
    testWidgets('should load app', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
      );
    });

    testWidgets('Login', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      await tester.pumpAndSettle();

      // Should show email and password fields
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Should show login button
      expect(find.byType(AuthButton), findsOneWidget);

      // Tap on field and type admin@example.com
      await tester.enterText(
        find.byType(TextFormField).first,
        'admin@example.com',
      );

      // Tap on field and type password
      await tester.enterText(find.byType(TextFormField).last, 'password');

      // Tap on login button
      await tester.tap(find.byType(AuthButton));

      // Wait for navigation
      await tester.pumpAndSettle();

      // Should show home page
      expect(find.byType(MainPage), findsOneWidget);

      // Finds a button on app bar
      expect(find.byKey(const Key('settings')), findsOneWidget);

      // Tap on settings button
      await tester.tap(find.byKey(const Key('settings')));

      // Wait for navigation
      await tester.pumpAndSettle();

      // Should show settings page
      expect(find.byType(SettingsDialog), findsOneWidget);

      // Find logout key
      expect(find.byKey(const Key('logout')), findsOneWidget);

      // Tap on logout button
      await tester.tap(find.byKey(const Key('logout')));

      // Wait for navigation
      await tester.pumpAndSettle();

      // Should show login page
      expect(find.byType(LoginPage), findsOneWidget);
    });

    TextSpan? findSpanBySemantics(RichText richText, String label) {
      final rootSpan = richText.text;
      TextSpan? foundSpan;

      rootSpan.visitChildren((span) {
        // Cek apakah span memiliki semanticsLabel yang cocok
        if (span is TextSpan && span.semanticsLabel == label) {
          foundSpan = span;
          return false; // Stop
        }
        return true; // Lanjut
      });

      return foundSpan;
    }

    testWidgets('Register', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);

      // Find all RichText widgets
      final richTextFinder = find.byType(RichText);
      final richTexts = tester.widgetList<RichText>(richTextFinder);

      // Find the specific span
      TextSpan? registerSpan;
      for (final richText in richTexts) {
        registerSpan = findSpanBySemantics(richText, 'Show Register');
        if (registerSpan != null) break;
      }

      expect(registerSpan, isNotNull, reason: 'Could not find register span');

      // Simulate tap
      (registerSpan!.recognizer as TapGestureRecognizer).onTap!();
      await tester.pumpAndSettle();

      // Verify navigation to RegisterPage
      expect(find.byType(RegisterPage), findsOneWidget);

      // Fill name form
      await tester.enterText(
        find.byType(TextFormField).first,
        'John Doe',
      );

      // Fill email form
      await tester.enterText(
        find.byType(TextFormField).last,
        'john.doe@example.com',
      );

      // Fill password form
      await tester.enterText(
        find.byType(TextFormField).last,
        'password',
      );

      // Tap on register button
      await tester.tap(find.byType(AuthButton));
      await tester.pumpAndSettle();

      // Verify snackbar appeared
      expect(find.byType(SnackBar), findsOneWidget);
      // Verify "Register success, please login" message
      expect(find.text('Register success, please login'), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify navigation to LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
