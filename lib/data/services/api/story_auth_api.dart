import 'package:dicoding_story/data/services/api/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/api/model/login_response/login_response.dart';
import 'package:dicoding_story/data/services/api/model/register_request/register_request.dart';
import 'package:dio/dio.dart';
import 'package:dicoding_story/utils/result.dart';

class StoryAuthApi {
  final Dio _dio;
  final String _baseUrl = 'https://story-api.dicoding.dev/v1';

  StoryAuthApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<Result<String?>> register(RegisterRequest registerRequest) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: registerRequest,
      );
      return Ok(response.data['message']);
    } on DioException catch (e) {
      return Error(
        Exception(e.response?.data['message'] ?? 'Failed to register'),
      );
    }
  }

  Future<Result<LoginResponse>> login(LoginRequest loginRequest) async {
    try {
      final response = await _dio.post('$_baseUrl/login', data: loginRequest);
      return Ok(response.data);
    } on DioException catch (e) {
      return Error(Exception(e.response?.data['message'] ?? 'Failed to login'));
    }
  }
}
