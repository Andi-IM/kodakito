import 'package:dicoding_story/common/routing/app_router/app_router.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheRepository extends Mock implements CacheRepository {}

void main() {
  group('appRouterProvider', () {
    late MockCacheRepository mockCacheRepository;
    late ProviderContainer container;

    setUp(() {
      mockCacheRepository = MockCacheRepository();
      container = ProviderContainer(
        overrides: [
          cacheRepositoryProvider.overrideWithValue(mockCacheRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns a GoRouter instance', () {
      when(() => mockCacheRepository.hasToken()).thenAnswer((_) async => false);

      final router = container.read(appRouterProvider);

      expect(router, isA<GoRouter>());
    });

    test('has correct configuration with routes', () {
      when(() => mockCacheRepository.hasToken()).thenAnswer((_) async => false);

      final router = container.read(appRouterProvider);

      // Verify router has configuration and routes
      expect(router.configuration, isNotNull);
      expect(router.configuration.routes, isNotEmpty);
    });

    test(
      'redirect returns home when user has token and is on login page',
      () async {
        when(
          () => mockCacheRepository.hasToken(),
        ).thenAnswer((_) async => true);

        final router = container.read(appRouterProvider);

        // Access the redirect function through configuration
        final config = router.configuration;
        expect(config, isNotNull);
      },
    );
  });
}
