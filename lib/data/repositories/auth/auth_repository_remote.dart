import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_data_source.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class AuthRepositoryRemote extends AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepositoryRemote({required AuthDataSource authDataSource})
    : _authDataSource = authDataSource;

  @override
  Future<Either<AppException, void>> register({
    required String email,
    required String password,
    required String name,
  }) {
    return _authDataSource.register(
      registerRequest: RegisterRequest(
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  @override
  Future<Either<AppException, void>> login({
    required String email,
    required String password,
  }) {
    return _authDataSource.login(
      LoginRequest(email: email, password: password),
    );
  }

  @override
  Future<Either<AppException, void>> logout() {
    throw UnimplementedError();
  }
}
