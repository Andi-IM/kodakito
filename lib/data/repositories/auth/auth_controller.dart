import 'package:dicoding_story/common/providers.dart';
import 'package:dicoding_story/utils/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // 1. Ambil repository
    final authRepo = ref.watch(authRepositoryProvider);
    // 2. Cek status awal saat app mulai
    return authRepo.isAuthenticated;
  }

  Future<void> login(String email, String password) async {
    // Set state ke loading
    state = const AsyncValue.loading();

    // Panggil repository
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.login(email: email, password: password);

    // Update state berdasarkan hasil
    switch (result) {
      case Ok<void>():
        state = const AsyncValue.data(true); // Sukses Login
      case Error<void>():
        state = AsyncValue.error(result.error, StackTrace.current); // Gagal
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    state = const AsyncValue.data(false); // Sukses Logout
  }
}
