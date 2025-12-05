import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_remote.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/auth_repository.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Domain Providers', () {
    test('providers should exist and return correct repository types', () {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.development),
        ],
      );
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(authRepositoryProvider), isA<AuthRepository>());

      expect(container.read(cacheRepositoryProvider), isA<CacheRepository>());

      expect(container.read(listRepositoryProvider), isA<ListRepository>());

      expect(container.read(detailRepositoryProvider), isA<DetailRepository>());
    });

    test('providers should return remote repositories in production', () {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.production),
        ],
      );
      addTearDown(container.dispose);

      // Act & Assert
      expect(
        container.read(authRepositoryProvider),
        isA<AuthRepositoryRemote>(),
      );

      expect(
        container.read(listRepositoryProvider),
        isA<ListRepositoryRemote>(),
      );

      expect(
        container.read(detailRepositoryProvider),
        isA<DetailRepositoryRemote>(),
      );
    });
  });
}
