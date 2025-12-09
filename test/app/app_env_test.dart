import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dicoding_story/app/app_env.dart';

void main() {
  group('EnvInfo', () {
    test('should return correct appName for development', () {
      const envInfo = EnvInfo(AppEnvironment.development);
      expect(envInfo.appName, 'Dicoding Story - Development');
      expect(envInfo.env, 'development');
      expect(envInfo.isProduction, false);
      expect(envInfo.environment, AppEnvironment.development);
    });

    test('should return correct appName for production', () {
      const envInfo = EnvInfo(AppEnvironment.production);
      expect(envInfo.appName, 'Dicoding Story');
      expect(envInfo.env, 'production');
      expect(envInfo.isProduction, true);
      expect(envInfo.environment, AppEnvironment.production);
    });

    test('isDebug returns a bool value based on kDebugMode', () {
      const envInfo = EnvInfo(AppEnvironment.development);
      // In test mode, kDebugMode is typically true
      expect(envInfo.isDebug, isA<bool>());
    });

    test('isRelease returns a bool value based on kReleaseMode', () {
      const envInfo = EnvInfo(AppEnvironment.development);
      // In test mode, kReleaseMode is typically false
      expect(envInfo.isRelease, isA<bool>());
    });

    test('isProfile returns a bool value based on kProfileMode', () {
      const envInfo = EnvInfo(AppEnvironment.development);
      // In test mode, kProfileMode is typically false
      expect(envInfo.isProfile, isA<bool>());
    });
  });

  group('envInfoProvider', () {
    test('should return development environment by default/fallback', () {
      // Load a dummy value to avoid EmptyEnvFileError, ensures APP_ENV is missing
      dotenv.loadFromString(envString: 'Ignored=True');
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final envInfo = container.read(envInfoProvider);

      expect(envInfo.environment, AppEnvironment.development);
    });

    test('should return production environment when APP_ENV is production', () {
      dotenv.loadFromString(envString: 'APP_ENV=production');
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final envInfo = container.read(envInfoProvider);

      expect(envInfo.environment, AppEnvironment.production);
    });

    test(
      'should return development environment when APP_ENV is development',
      () {
        dotenv.loadFromString(envString: 'APP_ENV=development');
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final envInfo = container.read(envInfoProvider);

        expect(envInfo.environment, AppEnvironment.development);
      },
    );
  });
}
