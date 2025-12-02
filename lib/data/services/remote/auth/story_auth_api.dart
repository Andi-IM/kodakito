import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';

class StoryAuthApi {
  final NetworkService networkService;

  StoryAuthApi({required this.networkService});

  Future<Either<AppException, String?>> register({
    required RegisterRequest registerRequest,
  }) async {
    try {
      final response = await networkService.post(
        '/register',
        body: registerRequest.toJson(),
      );

      return response.fold(
        (error) => Left(error),
        (response) => Right(response.data),
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Unknown error occured',
          statusCode: 1,
          identifier: '${e.toString()}\nStoryAuthApi.register',
        ),
      );
    }
  }

  Future<Either<AppException, LoginResponse>> login(
    LoginRequest loginRequest,
  ) async {
    try {
      final response = await networkService.post(
        '/login',
        body: loginRequest.toJson(),
      );
      return response.fold(
        (error) => Left(error),
        (response) => Right(response.data),
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Unknown error occured',
          statusCode: 1,
          identifier: '${e.toString()}\nStoryAuthApi.login',
        ),
      );
    }
  }
}
