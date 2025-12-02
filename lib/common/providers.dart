import 'package:dicoding_story/data/repositories/auth/auth_controller.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_dev.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/data/services/remote/story_api.dart';
import 'package:dicoding_story/data/services/remote/story_auth_api.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/data/services/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final apiClientProvider = Provider<StoryApi>(
  (ref) => throw UnimplementedError(),
);
final authApiClientProvider = Provider<StoryAuthApi>(
  (ref) => throw UnimplementedError(),
);
final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>(
  (ref) => throw UnimplementedError(),
);
final localDataServiceProvider = Provider<LocalDataService>(
  (ref) => throw UnimplementedError(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError(),
);
final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(() {
  return AuthController();
});

List<Override> get overridesRemote {
  return [
    // Services
    apiClientProvider.overrideWith((ref) => StoryApi()),
    authApiClientProvider.overrideWith((ref) => StoryAuthApi()),
    sharedPreferencesServiceProvider.overrideWith(
      (ref) => SharedPreferencesService(),
    ),

    authRepositoryProvider.overrideWith(
      (ref) => AuthRepositoryRemote(
        storyApi: ref.read(apiClientProvider),
        storyAuthApi: ref.read(authApiClientProvider),
        sharedPreferencesService: ref.read(sharedPreferencesServiceProvider),
      ),
    ),
  ];
}

List<Override> get overridesDev {
  return [authRepositoryProvider.overrideWith((ref) => AuthRepositoryDev())];
}
