import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/app/observer.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'fake/fake_cache_repository.dart';
import 'robot/add_story_robot.dart';
import 'robot/login_robot.dart';
import 'robot/logout_robot.dart';
import 'robot/register_robot.dart';
import 'robot/view_story_robot.dart';

/// This Integration Test launches the app with the local configuration
/// Make sure to set the environment variable to 'development' before running this test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Initialize environment statically for tests
  EnvInfo.initialize(AppEnvironment.development);

  group('end-to-end test with local data', () {
    testWidgets('should load app', (tester) async {
      await tester.pumpWidget(
        ProviderScope(observers: [Observer()], child: MyApp()),
      );
    });

    testWidgets('Login flow - user can login and navigate to main page', (
      tester,
    ) async {
      final loginRobot = LoginRobot(tester);
      await loginRobot.loadUI(
        ProviderScope(observers: [Observer()], child: MyApp()),
      );
      await loginRobot.typeEmail('admin@example.com');
      await loginRobot.typePassword('password');
      await loginRobot.tapLoginButton();
      await loginRobot.checkLoginResult();
    });

    testWidgets('Logout flow - user can logout and return to login page', (
      tester,
    ) async {
      // Setup: Start with authenticated user (simulating already logged in)
      final logoutRobot = LogoutRobot(tester);
      final repo = FakeCacheRepository();
      repo.saveToken(
        cache: Cache(token: 'token', userName: 'username', userId: 'userid'),
      );
      final overrideCache = cacheRepositoryProvider.overrideWithValue(repo);
      await logoutRobot.loadUI(
        ProviderScope(
          overrides: [overrideCache],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      await logoutRobot.tapAvatarButton();
      await logoutRobot.tapLogoutButton();
      await logoutRobot.checkLogoutResult();
    });

    testWidgets('Register - user can register and navigate to login page', (
      tester,
    ) async {
      final registerRobot = RegisterRobot(tester);
      await registerRobot.loadUI(
        ProviderScope(observers: [Observer()], child: MyApp()),
      );

      await registerRobot.findRegisterPage();
      await registerRobot.typeName('John Doe');
      await registerRobot.typeEmail('john.doe@example.com');
      await registerRobot.typePassword('password');
      await registerRobot.tapRegisterButton();
      await registerRobot.checkSnackbar();
      await registerRobot.checkLoginPage();
    });

    testWidgets(
      'View Story - user can view story and navigate to detail page',
      (tester) async {
        await mockNetworkImages(() async {
          final viewStoryRobot = ViewStoryRobot(tester);
          final repo = FakeCacheRepository();
          repo.saveToken(
            cache: Cache(
              token: 'token',
              userName: 'username',
              userId: 'userid',
            ),
          );

          final overrideCache = cacheRepositoryProvider.overrideWithValue(repo);

          await viewStoryRobot.loadUI(
            ProviderScope(
              overrides: [overrideCache],
              observers: [Observer()],
              child: MyApp(),
            ),
          );

          viewStoryRobot.verifyPageIsLoading();
          await viewStoryRobot.verifyStoryCardIsDisplayed();
          final story = await viewStoryRobot.tapStoryCard(0);
          await viewStoryRobot.verifyStoryDetailIsDisplayedWithStory(story);
        });
      },
    );

    testWidgets('Add Story - user can add story and verify story is added', (
      tester,
    ) async {
      final addStoryRobot = AddStoryRobot(tester);
      final repo = FakeCacheRepository();
      repo.saveToken(
        cache: Cache(token: 'token', userName: 'username', userId: 'userid'),
      );

      final overrideCache = cacheRepositoryProvider.overrideWithValue(repo);

      await addStoryRobot.grantPermission();

      await addStoryRobot.loadUI(
        ProviderScope(
          overrides: [overrideCache],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      await addStoryRobot.tapAddStoryButton();

      await addStoryRobot.revokePermission();
    });
  });
}
