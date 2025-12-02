import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';



abstract class AuthRepository {
  /// Register a new user
  Future<Either<AppException, void>> register({
    required String email,
    required String password,
    required String name,
  });

  /// Login a user
  Future<Either<AppException, void>> login({
    required String email,
    required String password,
  });

  /// Logout a user
  Future<Either<AppException, void>> logout();
}
