import 'package:dicoding_story/data/repositories/auth/auth_repository.dart';
import 'package:dicoding_story/utils/result.dart';

class AuthRepositoryDev extends AuthRepository {
  @override
  Future<bool> get isAuthenticated => Future.value(true);

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return Ok(null);
  }

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    return Ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    return Ok(null);
  }
}
