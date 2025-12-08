import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class Login extends _$Login with LogMixin {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login({required String email, required String password}) async {
    log.info('Attempting login for user: $email');
    final authRepository = ref.read(authRepositoryProvider);
    final cacheRepository = ref.read(cacheRepositoryProvider);
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
        final hasToken = await cacheRepository.saveToken(
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
}

class LoginMock extends _$Login with Mock implements Login {}

@riverpod
Future<bool> logout(Ref ref) async {
  final log = Logger('LogoutProvider');
  log.info('Attempting logout');
  final cacheRepository = ref.read(cacheRepositoryProvider);
  final result = await cacheRepository.deleteToken();
  if (result) {
    log.info('Logout successful');
  } else {
    log.severe('Logout failed');
  }
  return result;
}

@riverpod
Future<String?> fetchUserData(Ref ref) async {
  final log = Logger('FetchUserDataProvider');
  final cache = ref.read(cacheRepositoryProvider);
  final result = await cache.getToken();
  return result.fold(
    (l) {
      log.warning('Failed to fetch user data: $l');
      return null;
    },
    (r) {
      log.info('User data fetched: ${r.userName}');
      return r.userName;
    },
  );
}

@riverpod
class Register extends _$Register with LogMixin {
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

class RegisterMock extends _$Register with Mock implements Register {}

@riverpod
class ObscurePassword extends _$ObscurePassword {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}

class ObscurePasswordMock extends _$ObscurePassword
    with Mock
    implements ObscurePassword {}
