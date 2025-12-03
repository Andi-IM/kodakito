import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class AuthRepositoryDev extends AuthRepository {
  @override
  Future<Either<AppException, void>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return Right(null);
  }

  @override
  Future<Either<AppException, void>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return Right(null);
  }

  @override
  Future<Either<AppException, void>> logout() async {
    return Right(null);
  }
}
