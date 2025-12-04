import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/app/observer.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'fake/fake_cahce_repository.dart';
import 'robot/login_robot.dart';
import 'robot/logout_robot.dart';
import 'robot/register_robot.dart';

/// This Integration Test launches the app with the local configuration
/// Make sure to set the environment variable to 'development' before running this test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test with local data', () {
    testWidgets('should load app', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
      );
    });

    testWidgets('Login flow - user can login and navigate to main page', (
      tester,
    ) async {
      final loginRobot = LoginRobot(tester);
      await loginRobot.loadUI(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
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
      await logoutRobot.loadUI(
        ProviderScope(
          overrides: [
            cacheRepositoryProvider.overrideWithValue(repo),
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      await logoutRobot.tapAvatarButton();
      await logoutRobot.tapLogoutButton();
      await logoutRobot.checkLogoutResult();
    });

    testWidgets('Register', (tester) async {
      final registerRobot = RegisterRobot(tester);
      await registerRobot.loadUI(
        ProviderScope(
          overrides: [
            appEnvironmentProvider.overrideWithValue(
              AppEnvironment.development,
            ),
          ],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      await registerRobot.findRegisterPage();
      await registerRobot.typeName('John Doe');
      await registerRobot.typeEmail('john.doe@example.com');
      await registerRobot.typePassword('password');
      await registerRobot.tapRegisterButton();
      await registerRobot.checkSnackbar();
      await registerRobot.checkLoginPage();
    });
  });
}
