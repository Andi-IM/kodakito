import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier with LogMixin {
  @override
  AuthState build() {
    return const AuthState.initial();
  }
  

  Future<void> login({required String email, required String password}) async {
    log.info('Attempting login for user: $email');
    final authRepository = ref.read(authRepositoryProvider);
    final cacheDatasource = ref.read(cacheDatasourceProvider);
    state = const AuthState.loading();

    final response = await authRepository.login(
      email: email,
      password: password,
    );
    await response.fold(
      (failure) async {
        state = AuthState.failure(failure);
      },
      (r) async {
        log.info('Login successful, saving token');
        final hasToken = await cacheDatasource.saveToken(
          cache: r.loginResult.toCache(),
        );
        if (hasToken) {
          log.info('Token saved successfully');
          state = const AuthState.loaded();
          return;
        }
        log.severe('Failed to save token');
        state = AuthState.failure(CacheFailureException());
      },
    );
  }

  Future<void> logout() async {}
}

@riverpod
class RegisterNotifier extends _$RegisterNotifier with LogMixin {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    log.info('Attempting register for user: $email');
    final authRepository = ref.read(authRepositoryProvider);
    state = const AuthState.loading();

    final response = await authRepository.register(
      email: email,
      password: password,
      name: name,
    );
    await response.fold(
      (failure) async {
        log.warning('Register failed: ${failure.message}');
        state = AuthState.failure(failure);
      },
      (r) async {
        log.info('Register successful');
        state = const AuthState.loaded();
      },
    );
  }
}
