import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  
  AsyncValue<bool> build() {
    return const AsyncValue.data(false);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {}

  Future<void> login({required String email, required String password}) async {
    final authRepository = ref.read(authRepositoryProvider);
    final userRepository = ref.read(userRepositoryProvider);
  }

  Future<void> logout() async {}
}
