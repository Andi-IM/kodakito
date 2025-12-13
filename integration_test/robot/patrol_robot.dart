import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/ui/home/widgets/home_screen.dart';
import 'package:dicoding_story/ui/home/widgets/story_card.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter/gestures.dart';
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

  Future<void> goToRegister() async {
    TextSpan? registerSpan;
    final richTextFinder = find.byType(RichText);
    final richTexts = $.tester.widgetList<RichText>(richTextFinder);

    for (final richText in richTexts) {
      registerSpan = findSpanBySemantics(richText, 'Show Register');
      if (registerSpan != null) break;
    }

    expect(registerSpan, isNotNull, reason: 'Could not find register span');

    (registerSpan!.recognizer as TapGestureRecognizer).onTap!();
    await $.tester.pumpAndSettle();
  }

  Future<void> typeName(String name) async {
    await $(#nameField).enterText(name);
  }

  Future<void> typeEmail(String email) async {
    await $(#emailField).enterText(email);
  }

  Future<void> typePassword(String password) async {
    await $(#passwordField).enterText(password);
  }

  Future<Either<AppException, Cache>> tapLoginButton() async {
    await $(#loginButton).tap(settlePolicy: SettlePolicy.settle);
    return await $.tester.container().read(cacheRepositoryProvider).getToken();
  }

  Future<void> tapRegisterButton() async {
    await $(#registerButton).tap(settlePolicy: SettlePolicy.trySettle);
  }

  Future<void> checkRegisterResult() async {
    await $('Register success, please login').waitUntilExists();
    await $(#loginButton).waitUntilExists();
  }

  Future<Either<AppException, Cache>> checkLoginResult() async {
    await $(HomeScreen).waitUntilExists();
    await $.tester.pumpAndSettle();
    return await $.tester.container().read(cacheRepositoryProvider).getToken();
  }

  Future<void> tapAddStoryButton() async {
    await $(Icons.add).tap();
    await $.pumpAndSettle();
  }

  Future<void> grantPermissionWhenVisible() async {
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.tap(Selector(text: 'Allow all'));
    }
    await $.pumpAndSettle();
  }

  Future<void> selectImageMobile() async {
    /// using coordinates for sampling
    await $.native.tapAt(Offset(0.370, 0.627));
    await $.native.tapAt(Offset(0.919, 0.05));
  }

  Future<void> fillDescription(String description) async {
    await $(#descriptionField).tap();
    await $(#descriptionField).enterText(description);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
  }

  Future<void> selectLocation() async {
    await $(#locationButton).tap();
    await $.pumpAndSettle();
  }

  Future<void> grantPermission() async {
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }
    await $.pumpAndSettle();
  }

  Future<void> confirmLocation() async {
    // delay 10 seconds
    await Future.delayed(const Duration(seconds: 10));
    await $(#confirmLocationButton).tap();
    await $.pumpAndSettle();
  }

  Future<void> tapPostButton() async {
    await $(#postButton).tap();
    await $.pumpAndSettle();
  }

  Future<void> checkAddStoryResult(String description) async {
    // await $(HomeScreen).waitUntilExists();
    await $(description).waitUntilExists();
  }

  Future<void> tapStory(String description) async {
    await $(description).tap();
    await $.pumpAndSettle();
  }

  Future<void> checkStoryDetailIsDisplayedWithStory(String description) async {
    await $(description).waitUntilExists();
    await $.native.pressBack();
    await $.pumpAndSettle();
  }

  Future<void> scrollToBottom() async {
    // count story list
    final storyList = $.tester.widgetList<StoryCard>(find.byType(StoryCard));
    // Verify we can find some cards
    expect(storyList, isNotEmpty);

    // Scroll CustomScrollView until target is visible
    await $.tester.scrollUntilVisible(
      find.byKey(const ValueKey('storycard_9')),
      500.0,
    );
    await $(const ValueKey('storycard_9')).waitUntilVisible();
  }

  Future<void> scrollAgain() async {
    await $(
      #storycard_10,
    ).scrollTo(scrollDirection: AxisDirection.down, step: 500);
    expect($(#storycard_10).visible, equals(true));

    await Future.delayed(const Duration(seconds: 3));
    // check list count
    final storyList = $.tester.widgetList<StoryCard>(find.byType(StoryCard));
    expect(storyList.length, moreOrLessEquals(20));
  }

  Future<void> scrollUp() async {
    await $(
      #storycard_0,
    ).scrollTo(scrollDirection: AxisDirection.up, step: 500);
  }

  Future<void> tapAvatarButton() async {
    await $(#avatarButton).waitUntilVisible();
    await $(#avatarButton).tap();
    await $.pumpAndSettle();
  }

  Future<void> tapThemeDarkDropdown() async {
    await $('Light').tap();
    await $.pumpAndSettle();
    await $('Dark').tap();
    await $.pumpAndSettle();
    await $('Dark').waitUntilVisible();
    final finder = find.byKey(const ValueKey('settingsDialog'));
    final Dialog widget = $.tester.widget<Dialog>(finder);
    expect(widget.backgroundColor, Color(0xff271d1d));
  }

  Future<void> tapThemeLightDropdown() async {
    await $('Dark').tap();
    await $.pumpAndSettle();
    await $('Light').tap();
    await $.pumpAndSettle();
    await $('Light').waitUntilVisible();
    final finder = find.byKey(const ValueKey('settingsDialog'));
    final Dialog widget = $.tester.widget<Dialog>(finder);
    expect(widget.backgroundColor, Color(0xfffceae8));
  }

  Future<void> tapIndonesianLanguage() async {
    await $('Language').tap();
    await $.pumpAndSettle();
    await $('Indonesian').tap();
    await $.pumpAndSettle();
    await $('Bahasa').waitUntilVisible();
  }

  Future<void> tapEnglishLanguage() async {
    await $('Bahasa').tap();
    await $.pumpAndSettle();
    await $('Bahasa Inggris').tap();
    await $.pumpAndSettle();
    await $('Language').waitUntilVisible();
  }

  Future<void> tapLogoutButton() async {
    await $(#logoutButton).tap();
    await $.pumpAndSettle();
  }

  Future<void> checkLogoutResult() async {
    await $(#loginButton).waitUntilExists();
  }
}
