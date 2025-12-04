import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/data/data_providers.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_dev.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/data/repositories/cache/cache_repository_local.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_local.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_remote.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_local.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
import 'package:dicoding_story/domain/repository/auth_repository.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/env/env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domain_providers.g.dart';

@riverpod
AppEnvironment appEnvironment(Ref ref) => Env.appEnvironment;

@riverpod
AuthRepository authRepository(Ref ref) {
  final env = ref.watch(appEnvironmentProvider);
  if (env == AppEnvironment.production) {
    return AuthRepositoryRemote(
      authDataSource: ref.read(authDataSourceProvider),
    );
  } else {
    return AuthRepositoryDev();
  }
}

@riverpod
CacheRepository cacheRepository(Ref ref) =>
    CacheRepositoryImpl(datasource: ref.read(cacheDatasourceProvider));

@riverpod
ListRepository listRepository(Ref ref) {
  final env = ref.watch(appEnvironmentProvider);
  if (env == AppEnvironment.production) {
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
  final env = ref.watch(appEnvironmentProvider);
  if (env == AppEnvironment.production) {
    return DetailRepositoryRemote(
      storyDataSource: ref.read(storyDataSourceProvider),
    );
  } else {
    return DetailRepositoryLocal(
      localDataService: ref.read(localDataServiceProvider),
    );
  }
}
