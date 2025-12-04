import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart' show MainPage;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginRobot {
  final WidgetTester tester;

  const LoginRobot(this.tester);

  final emailFieldKey = const ValueKey('emailField');
  final passwordFieldKey = const ValueKey('passwordField');
  final loginButtonKey = const ValueKey('loginButton');

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> typeEmail(String email) async {
    final emailFieldFinder = find.byKey(emailFieldKey);
    await tester.tap(emailFieldFinder);
    await tester.enterText(emailFieldFinder, email);
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  Future<void> typePassword(String password) async {
    final passwordFieldFinder = find.byKey(passwordFieldKey);
    await tester.tap(passwordFieldFinder);
    await tester.enterText(passwordFieldFinder, password);
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }

  Future<void> tapLoginButton() async {
    final loginButtonFinder = find.byKey(loginButtonKey);
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> checkLoginResult() async {
    final mainPageFinder = find.byType(MainPage);
    expect(mainPageFinder, findsOneWidget);
    await tester.container().read(cacheRepositoryProvider).deleteToken();
    await tester.pumpAndSettle();
  }
}
