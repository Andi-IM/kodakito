import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  /// Register a new user
  Future<Either<AppException, DefaultResponse>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Login a user
  Future<Either<AppException, LoginResponse>> login({
    required String email,
    required String password,
  });

  /// Logout a user
  Future<Either<AppException, void>> logout();
}
