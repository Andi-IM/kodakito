import 'package:dicoding_story/ui/auth/widgets/login_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class LogoutRobot {
  final WidgetTester tester;

  const LogoutRobot(this.tester);

  final avatarButtonKey = const ValueKey('avatarButton');
  final logoutButtonKey = const ValueKey('logoutButton');

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  Future<void> tapAvatarButton() async {
    final avatarButtonFinder = find.byKey(avatarButtonKey);
    await tester.tap(avatarButtonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapLogoutButton() async {
    final logoutButtonFinder = find.byKey(logoutButtonKey);
    await tester.tap(logoutButtonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> checkLogoutResult() async {
    final loginPageFinder = find.byType(LoginPage);
    expect(loginPageFinder, findsOneWidget);
  }
}
