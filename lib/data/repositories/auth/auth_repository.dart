import 'package:dicoding_story/utils/result.dart';

abstract class AuthRepository {
  /// Returns true when user is authenticated
  /// Returns [Future] because it will load a stored auth state for the first time.
  Future<bool> get isAuthenticated;

  /// Register a new user
  Future<Result<void>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Login a user
  Future<Result<void>> login({required String email, required String password});

  /// Logout a user
  Future<Result<void>> logout();
}
