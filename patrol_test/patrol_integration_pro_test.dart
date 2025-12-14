import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/main.dart';
import 'package:faker/faker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'patrol_robot.dart';

void main() {
  patrolTest(
    'Integration Test - Pro Flavor',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    config: PatrolTesterConfig(printLogs: true),
    ($) async {
      await initApp(AppEnvironment.paidProd);
      final robot = PatrolAddStoryRobot($);

      await robot.loadUI(ProviderScope(child: MyApp()));

      await robot.goToRegister();

      final fakeName = faker.person.name();
      final fakeEmail = faker.internet.email();
      final fakePassword = faker.internet.password(length: 8);

      await robot.typeName(fakeName);
      await robot.typeEmail(fakeEmail);
      await robot.typePassword(fakePassword);

      await robot.tapRegisterButton();
      await robot.checkRegisterResult();

      await robot.typeEmail(fakeEmail);
      await robot.typePassword(fakePassword);

      await robot.tapLoginButton();
      await robot.checkLoginResult();

      await robot.tapAddStoryButton();
      await robot.grantPermissionWhenVisible();

      final description = faker.lorem.sentence();
      await robot.selectImageMobile();
      await robot.fillDescription(description);
      await robot.selectLocation();
      await robot.grantPermission();
      await robot.confirmLocation();
      await robot.tapPostButton();
      await robot.checkAddStoryResult(description);

      await robot.tapStory(description);
      await robot.checkStoryDetailIsDisplayedWithStory(fakeName, description);

      await robot.scrollToBottom();
      await robot.scrollAgain();
      await robot.scrollUp();

      await robot.tapAvatarButton();

      await robot.tapThemeDarkDropdown();
      await robot.tapThemeLightDropdown();

      await robot.tapIndonesianLanguage();
      await robot.tapEnglishLanguage();

      await robot.tapLogoutButton();
      await robot.checkLogoutResult();
    },
  );
}
