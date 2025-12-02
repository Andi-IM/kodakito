import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<AppException, void>> login(LoginRequest loginRequest);
  Future<Either<AppException, void>> register(RegisterRequest registerRequest);
}

