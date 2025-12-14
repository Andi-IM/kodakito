import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/data/repositories/add/add_story_repository_local.dart';
import 'package:dicoding_story/data/repositories/add/add_story_repository_remote.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_dev.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_local.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_remote.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_local.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
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
      EnvInfo.initialize(AppEnvironment.freeDev);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(authRepositoryProvider), isA<AuthRepository>());

      expect(container.read(cacheRepositoryProvider), isA<CacheRepository>());

      expect(container.read(listRepositoryProvider), isA<ListRepository>());

      expect(container.read(detailRepositoryProvider), isA<DetailRepository>());

      expect(
        container.read(addStoryRepositoryProvider),
        isA<AddStoryRepository>(),
      );
    });

    test('providers should return remote repositories in production', () {
      // Arrange
      EnvInfo.initialize(AppEnvironment.freeProd);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
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

      expect(
        container.read(addStoryRepositoryProvider),
        isA<AddStoryRepositoryRemote>(),
      );
    });

    test('providers should return local/dev repositories in development', () {
      // Arrange
      EnvInfo.initialize(AppEnvironment.freeDev);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(authRepositoryProvider), isA<AuthRepositoryDev>());

      expect(
        container.read(listRepositoryProvider),
        isA<ListRepositoryLocal>(),
      );

      expect(
        container.read(detailRepositoryProvider),
        isA<DetailRepositoryLocal>(),
      );

      expect(
        container.read(addStoryRepositoryProvider),
        isA<AddStoryRepositoryLocal>(),
      );
    });
  });
}
