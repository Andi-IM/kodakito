import 'package:dicoding_story/ui/auth/widgets/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class RegisterRobot {
  final WidgetTester tester;

  RegisterRobot(this.tester);

  final nameFieldKey = const ValueKey('nameField');
  final emailFieldKey = const ValueKey('emailField');
  final passwordFieldKey = const ValueKey('passwordField');
  final registerButtonKey = const ValueKey('registerButton');

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

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

  Future<void> findRegisterPage() async {
    TextSpan? registerSpan;
    final richTextFinder = find.byType(RichText);
    final richTexts = tester.widgetList<RichText>(richTextFinder);

    for (final richText in richTexts) {
      registerSpan = findSpanBySemantics(richText, 'Show Register');
      if (registerSpan != null) break;
    }

    expect(registerSpan, isNotNull, reason: 'Could not find register span');

    (registerSpan!.recognizer as TapGestureRecognizer).onTap!();
    await tester.pumpAndSettle();
  }

  Future<void> typeName(String name) async {
    final nameFieldFinder = find.byKey(nameFieldKey);
    await tester.tap(nameFieldFinder);
    await tester.enterText(nameFieldFinder, name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
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

  Future<void> tapRegisterButton() async {
    final registerButtonFinder = find.byKey(registerButtonKey);
    await tester.tap(registerButtonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> checkSnackbar() async {
    // Verify snackbar appeared
    expect(find.byType(SnackBar), findsOneWidget);
    // Verify "Register success, please login" message
    expect(find.text('Register success, please login'), findsOneWidget);

    await tester.pumpAndSettle();
  }

  Future<void> checkLoginPage() async {
    final loginPageFinder = find.byType(LoginScreen);
    expect(loginPageFinder, findsOneWidget);
    await tester.pumpAndSettle();
  }
}
