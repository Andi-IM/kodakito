import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';

abstract class AuthDataSource {
  Future<Either<AppException, DefaultResponse>> register({
    required RegisterRequest registerRequest,
  });

  Future<Either<AppException, LoginResponse>> login(LoginRequest loginRequest);
}

class StoryAuthApi implements AuthDataSource {
  final NetworkService networkService;

  StoryAuthApi({required this.networkService});

  @override
  Future<Either<AppException, DefaultResponse>> register({
    required RegisterRequest registerRequest,
  }) async {
    try {
      final response = await networkService.post(
        '/register',
        data: registerRequestToJson(registerRequest),
      );

      return response.fold(
        (error) => Left(error),
        (response) => Right(DefaultResponse.fromJson(response.data)),
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

  @override
  Future<Either<AppException, LoginResponse>> login(
    LoginRequest loginRequest,
  ) async {
    try {
      final response = await networkService.post(
        '/login',
        data: loginRequestToJson(loginRequest),
      );
      return response.fold((error) => Left(error), (response) {
        final loginResponse = LoginResponse.fromJson(response.data);
        networkService.updateHeader({
          'Authorization': 'Bearer ${loginResponse.loginResult.token}',
        });
        return Right(loginResponse);
      });
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
