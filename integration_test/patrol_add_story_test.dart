import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'robot/patrol_add_story_robot.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  patrolTest(
    'Add story',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    config: PatrolTesterConfig(printLogs: true),
    ($) async {
      await initApp();
      final robot = PatrolAddStoryRobot($);

      await robot.loadUI(ProviderScope(child: MyApp()));

      await robot.typeEmail(dotenv.get("TEST_EMAIL"));
      await robot.typePassword(dotenv.get("TEST_PASSWORD"));
      await robot.tapLoginButton();
      await robot.checkLoginResult();

      await robot.tapAddStoryButton();
      await robot.grantPermissionWhenVisible();

      await robot.selectImageMobile();
    },
  );
}
