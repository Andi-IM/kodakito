import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_button.dart';
import 'package:dicoding_story/ui/auth/widgets/register_screen.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('renders RegisterPage correctly', (WidgetTester tester) async {
    final mockNotifier = RegisterMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Register'), findsOneWidget); // Title or Button
    expect(
      find.byType(TextFormField),
      findsNWidgets(3),
    ); // Name, Email, Password
    expect(find.byType(AuthButton), findsOneWidget);
  });

  testWidgets('enters name, email and password', (WidgetTester tester) async {
    final mockNotifier = RegisterMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Act
    final nameField = find.byType(TextFormField).at(0);
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'John Doe');
    await tester.pump();

    final emailField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    final passwordField = find.byType(TextFormField).at(2);
    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Assert
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });

  testWidgets('calls register when button is pressed', (
    WidgetTester tester,
  ) async {
    final mockNotifier = RegisterMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());
    when(
      () => mockNotifier.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Act
    final nameField = find.byType(TextFormField).at(0);
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'John Doe');
    await tester.pump();

    final emailField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    final passwordField = find.byType(TextFormField).at(2);
    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    final button = find.byType(AuthButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    // Assert
    verify(
      () => mockNotifier.register(
        name: 'John Doe',
        email: 'test@example.com',
        password: 'password123',
      ),
    ).called(1);
  });
  testWidgets('toggles password visibility icon when clicked', (
    WidgetTester tester,
  ) async {
    final mockNotifier = RegisterMock();
    when(() => mockNotifier.build()).thenReturn(const AuthState.initial());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: obscure = true, icon = visibility_outlined
    final iconFinder = find.byIcon(Icons.visibility_outlined);
    expect(iconFinder, findsOneWidget);

    // Act: Tap toggle button
    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pump();

    // Assert: icon changed to visibility_off_outlined
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);

    // Act: Tap again
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    // Assert: icon changed back to visibility_outlined
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
  });

  testWidgets('shows snackbar on register failure', (
    WidgetTester tester,
  ) async {
    final mockNotifier = TestableRegisterNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Simulate a failure state transition
    mockNotifier.setTestState(
      AuthState.failure(
        AppException(
          message: 'Email already exists',
          statusCode: 400,
          identifier: 'register',
        ),
      ),
    );
    await tester.pump();

    // Verify snackbar is shown with error message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Email already exists'), findsOneWidget);
  });

  testWidgets('calls onRegisterSuccess when register succeeds', (
    WidgetTester tester,
  ) async {
    final mockNotifier = TestableRegisterNotifier();
    var registerSuccessCalled = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [registerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(
            onRegisterSuccess: () {
              registerSuccessCalled = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify callback not called yet
    expect(registerSuccessCalled, isFalse);

    // Simulate a loaded state transition
    mockNotifier.setTestState(const AuthState.loaded());
    await tester.pump();

    // Verify onRegisterSuccess callback was called
    expect(registerSuccessCalled, isTrue);
  });
}

/// Testable RegisterNotifier that allows custom state updates
class TestableRegisterNotifier extends Register {
  @override
  AuthState build() => const AuthState.initial();

  void setTestState(AuthState newState) {
    state = newState;
  }
}
