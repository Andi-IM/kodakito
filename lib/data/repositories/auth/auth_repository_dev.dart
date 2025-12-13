import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/domain/repository/auth_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class AuthRepositoryDev extends AuthRepository {
  @override
  Future<Either<AppException, DefaultResponse>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => Right(DefaultResponse(error: false, message: '')),
    );
  }

  @override
  Future<Either<AppException, LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    return await Future.delayed(
      const Duration(seconds: 2),
      () => Right(
        LoginResponse(
          loginResult: LoginResult(
            userId: 'user-asdf',
            name: 'Andi Irham',
            token: 'token',
          ),
          error: false,
          message: 'success',
        ),
      ),
    );
  }
}
