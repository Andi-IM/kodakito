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
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [loginProvider.overrideWith(() => LoginMock())],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginPage(),
      ),
    );
  }

  testWidgets('renders LoginPage correctly', (WidgetTester tester) async {
    final container = tester.container();
    // Arrange
    when(() => container.read(loginProvider)).thenReturn(const AuthState.initial());

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Login'), findsOneWidget); // Title or Button
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.byType(AuthButton), findsOneWidget);
  });

  testWidgets('enters email and password', (WidgetTester tester) async {
    final container = tester.container();
    // Arrange
    when(() => container.read(loginProvider)).thenReturn(const AuthState.initial());
    await tester.pumpWidget(createWidgetUnderTest());
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
    final container = tester.container();
    // Arrange
    when(() => container.read(loginProvider)).thenReturn(const AuthState.initial());
    when(
      () => container.read(loginProvider.notifier).login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
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
      () => container.read(loginProvider.notifier).login(
        email: 'test@example.com',
        password: 'password123',
      ),
    ).called(1);
  });
}
