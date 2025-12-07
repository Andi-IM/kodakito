import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_button.dart';
import 'package:dicoding_story/ui/auth/widgets/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('renders LoginPage correctly', (WidgetTester tester) async {
    final mockNotifier = LoginMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loginProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(goToRegister: () {}, onLoginSuccess: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Login'), findsOneWidget); // Title or Button
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.byType(AuthButton), findsOneWidget);
  });

  testWidgets('enters email and password', (WidgetTester tester) async {
    final mockNotifier = LoginMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loginProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(goToRegister: () {}, onLoginSuccess: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Act
    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');

    // Assert
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });

  testWidgets('calls login when button is pressed', (
    WidgetTester tester,
  ) async {
    final mockNotifier = LoginMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());
    when(
      () => mockNotifier.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loginProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(goToRegister: () {}, onLoginSuccess: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Act
    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.byType(AuthButton));
    await tester.pump();

    // Assert
    verify(
      () => mockNotifier.login(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).called(1);
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    final mockNotifier = LoginMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loginProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(goToRegister: () {}, onLoginSuccess: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find password field (TextField inside TextFormField)
    final passwordFieldFinder = find.descendant(
      of: find.byType(TextFormField).last,
      matching: find.byType(TextField),
    );
    final passwordField = tester.widget<TextField>(passwordFieldFinder);

    // Initial state: obscureText should be true
    expect(passwordField.obscureText, isTrue);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Tap the visibility toggle button
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    // Verify state changed: obscureText should be false
    final passwordFieldAfterTap = tester.widget<TextField>(passwordFieldFinder);
    expect(passwordFieldAfterTap.obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
