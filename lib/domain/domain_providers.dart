import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/domain/repository/auth_repository.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_dev.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_local.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_remote.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_local.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/data/services/local/shared_prefs_storage_service.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_data_source.dart';
import 'package:dicoding_story/data/services/remote/dio_netowork_service.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/env/env.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domain_providers.g.dart';

@riverpod
SharedPrefsService storageService(Ref ref) {
  final prefsService = SharedPrefsService();
  prefsService.init();
  return prefsService;
}

@riverpod
DioNetworkService dioNetworkService(Ref ref) => DioNetworkService(Dio());

@riverpod
AuthDataSource authDataSource(Ref ref) =>
    StoryAuthApi(networkService: ref.read(dioNetworkServiceProvider));

@riverpod
AuthRepository authRepository(Ref ref) {
  if (Env.appEnvironment == AppEnvironment.production) {
    return AuthRepositoryRemote(
      authDataSource: ref.read(authDataSourceProvider),
    );
  } else {
    return AuthRepositoryDev();
  }
}

@riverpod
CacheDatasource cacheDatasource(Ref ref) =>
    CacheDatasourceImpl(storageService: ref.read(storageServiceProvider));

@riverpod
StoryDataSource storyDataSource(Ref ref) =>
    StoryRemoteDataSource(networkService: ref.read(dioNetworkServiceProvider));

@riverpod
LocalDataService localDataService(Ref ref) => LocalDataService();

@riverpod
ListRepository listRepository(Ref ref) {
  if (Env.appEnvironment == AppEnvironment.production) {
    return ListRepositoryRemote(
      storyDataSource: ref.read(storyDataSourceProvider),
    );
  } else {
    return ListRepositoryLocal(
      localDataService: ref.read(localDataServiceProvider),
    );
  }
}

@riverpod
DetailRepository detailRepository(Ref ref) {
  if (Env.appEnvironment == AppEnvironment.production) {
    return DetailRepositoryRemote(
      storyDataSource: ref.read(storyDataSourceProvider),
    );
  } else {
    return DetailRepositoryLocal(
      localDataService: ref.read(localDataServiceProvider),
    );
  }
}
