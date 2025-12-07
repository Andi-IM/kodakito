import 'package:dicoding_story/common/globals.dart';
import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/data/services/local/shared_prefs_storage_service.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_data_source.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_interceptor.dart';
import 'package:dicoding_story/data/services/remote/dio_network_service.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

@riverpod
SharedPrefsService storageService(Ref ref) {
  final prefsService = SharedPrefsService();
  prefsService.init();
  return prefsService;
}

@riverpod
AuthInterceptor authInterceptor(Ref ref) =>
    AuthInterceptor(ref.read(cacheDatasourceProvider));

@riverpod
Dio dio(Ref ref) => Dio();

@riverpod
NetworkImageService networkImageService(Ref ref) {
  final dio = ref.read(dioProvider);
  return DioImageService(dio);
}

@riverpod
DioNetworkService dioNetworkService(Ref ref) {
  final dio = ref.read(dioProvider);

  // coverage:ignore-start
  if (!kTestMode) {
    // coverage:ignore-line
    final dioBaseOptions = BaseOptions(
      baseUrl: dotenv.get("APP_URL", fallback: "localhost:8000"),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    dio.options = dioBaseOptions;
    dio.interceptors.add(ref.read(authInterceptorProvider));
    if (kDebugMode) {
      // coverage:ignore-line
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }
  // coverage:ignore-end
  return DioNetworkService(dio);
}

@riverpod
AuthDataSource authDataSource(Ref ref) =>
    StoryAuthApi(networkService: ref.read(dioNetworkServiceProvider));

@riverpod
CacheDatasource cacheDatasource(Ref ref) =>
    CacheDatasourceImpl(storageService: ref.read(storageServiceProvider));

@riverpod
LocalDataService localDataService(Ref ref) => LocalDataService();

@riverpod
StoryDataSource storyDataSource(Ref ref) =>
    StoryRemoteDataSource(networkService: ref.read(dioNetworkServiceProvider));
