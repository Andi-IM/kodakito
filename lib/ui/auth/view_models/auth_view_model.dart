import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login({required String email, required String password}) async {
    final authRepository = ref.read(authRepositoryProvider);
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
        state = const AuthState.loaded();
      },
    );
  }

  Future<void> logout() async {}
}

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AuthState.loading();

    final response = await authRepository.register(
      email: email,
      password: password,
      name: name,
    );
    await response.fold(
      (failure) async {
        state = AuthState.failure(failure);
      },
      (r) async {
        state = const AuthState.loaded();
      },
    );
  }
}
