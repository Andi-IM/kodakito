import 'package:dicoding_story/data/data_providers.dart';
import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/data/services/local/shared_prefs_storage_service.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_data_source.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_interceptor.dart';
import 'package:dicoding_story/data/services/remote/dio_network_service.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Data Providers', () {
    test('providers should exist and return correct types', () {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(storageServiceProvider), isA<SharedPrefsService>());

      expect(
        container.read(dioNetworkServiceProvider),
        isA<DioNetworkService>(),
      );

      expect(container.read(authDataSourceProvider), isA<AuthDataSource>());

      expect(container.read(cacheDatasourceProvider), isA<CacheDatasource>());

      expect(container.read(localDataServiceProvider), isA<LocalDataService>());

      expect(container.read(storyDataSourceProvider), isA<StoryDataSource>());

      expect(container.read(authInterceptorProvider), isA<AuthInterceptor>());
    });
  });
}
