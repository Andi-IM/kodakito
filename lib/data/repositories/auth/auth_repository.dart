import 'package:dicoding_story/app/app_env.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_dev.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/env/env.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';
import 'package:riverpod_repo/annotations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';
part 'auth_repository.repo.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  if (Env.appEnvironment == AppEnvironment.production) {
    return AuthRepositoryRemote(
      storyApi: ref.watch(storyApiProvider),
      storyAuthApi: ref.watch(storyAuthApiProvider),
      sharedPreferencesService: ref.watch(sharedPreferencesServiceProvider),
    );
  } else {
    return AuthRepositoryDev();
  }
}

@riverpodRepo
abstract class AuthRepository {
  /// Returns true when user is authenticated
  /// Returns [Future] because it will load a stored auth state for the first time.
  Future<bool> get isAuthenticated;

  /// Register a new user
  Future<Either<AppException, void>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Login a user
  Future<Either<AppException, void>> login({
    required String email,
    required String password,
  });

  /// Logout a user
  Future<Either<AppException, void>> logout();
}
