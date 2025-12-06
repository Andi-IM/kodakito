import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/ui/main/widgets/main_page.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

class PatrolAddStoryRobot {
  final PatrolIntegrationTester $;

  PatrolAddStoryRobot(this.$);

  Future<void> loadUI(Widget widget) async {
    await $.pumpWidgetAndSettle(widget);
  }

  Future<void> typeEmail(String email) async {
    await $(#emailField).tap();
    await $(#emailField).enterText(email);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
  }

  Future<void> typePassword(String password) async {
    await $(#passwordField).tap();
    await $(#passwordField).enterText(password);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
  }

  Future<Either<AppException, Cache>> tapLoginButton() async {
    await $(#loginButton).tap();
    await $.pumpAndSettle();
    return await $.tester.container().read(cacheRepositoryProvider).getToken();
  }

  Future<void> checkLoginResult() async {
    await $(MainPage).waitUntilExists();
    await $.tester.container().read(cacheRepositoryProvider).deleteToken();
    await $.tester.pumpAndSettle();
  }

  Future<void> tapAddStoryButton() async {
    await $(Icons.add).tap();
    await $.pumpAndSettle();
  }

  Future<void> grantPermissionWhenVisible() async {
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.tap(Selector(text: 'Allow all'));
    }
  }

  Future<void> selectImageMobile() async {
    // verify child of gridFinder is not empty
    final mediaId = find.byKey(Key('44'));
    mediaId.evaluate().forEach((element) {
      print('Element candidate: $element');
    });
    await $(mediaId).tap();
  }
}
