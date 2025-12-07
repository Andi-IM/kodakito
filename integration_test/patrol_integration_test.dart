import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'robot/patrol_add_story_robot.dart';
import 'package:faker/faker.dart';

void main() {
  patrolTest(
    'Integration Test',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    config: PatrolTesterConfig(printLogs: true),
    ($) async {
      await initApp();
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
      await robot.tapPostButton();
      await robot.checkAddStoryResult(description);

      await robot.tapStory(description);
      await robot.checkStoryDetailIsDisplayedWithStory(description);

      await robot.tapAvatarButton();

      await robot.tapThemeLightDropdown();
      await robot.tapThemeDarkDropdown();

      await robot.tapIndonesianLanguage();
      await robot.tapEnglishLanguage();

      await robot.tapLogoutButton();
      await robot.checkLogoutResult();
    },
  );
}
