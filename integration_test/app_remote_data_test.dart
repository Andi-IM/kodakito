import 'package:dicoding_story/app/app.dart';
import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/app/observer.dart';
import 'package:dicoding_story/data/data_providers.dart'
    show authInterceptorProvider, cacheDatasourceProvider;
import 'package:dicoding_story/data/services/remote/auth/auth_interceptor.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/env/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'fake/fake_cache_datasource.dart';
import 'robot/login_robot.dart';
import 'robot/view_story_robot.dart';

/// This Integration Test launches the app with the remote configuration
/// Make sure to set the environment variable to 'production' before running this test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final overrideEnv = appEnvironmentProvider.overrideWithValue(
    AppEnvironment.production,
  );

  String token = '';

  group('end-to-end test with remote data', () {
    testWidgets('should load app', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [overrideEnv],
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
          overrides: [overrideEnv],
          observers: [Observer()],
          child: MyApp(),
        ),
      );
      await loginRobot.typeEmail(Env.testEmail);
      await loginRobot.typePassword(Env.testPassword);
      final result = await loginRobot.tapLoginButton();
      result.fold((l) => fail('Should not return Left'), (r) {
        token = r.token;
      });
      await loginRobot.checkLoginResult();
    });
  });

  testWidgets('View Story - user can view story and navigate to detail page', (
    tester,
  ) async {
    await mockNetworkImages(() async {
      final viewStoryRobot = ViewStoryRobot(tester);
      final cacheDatasource = FakeCacheDatasource();
      cacheDatasource.saveToken(
        cache: Cache(token: token, userName: 'username', userId: 'userid'),
      );

      final overrideCache = cacheDatasourceProvider.overrideWithValue(
        cacheDatasource,
      );
      final overrideAuth = authInterceptorProvider.overrideWithValue(
        AuthInterceptor(cacheDatasource),
      );

      await viewStoryRobot.loadUI(
        ProviderScope(
          overrides: [overrideEnv, overrideAuth, overrideCache],
          observers: [Observer()],
          child: MyApp(),
        ),
      );

      viewStoryRobot.verifyPageIsLoading();
      await viewStoryRobot.verifyStoryCardIsDisplayed();
      final story = await viewStoryRobot.tapStoryCard(0);
      await viewStoryRobot.verifyStoryDetailIsDisplayedWithStory(story);
    });
  });
}
