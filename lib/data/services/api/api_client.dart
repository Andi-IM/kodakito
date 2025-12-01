import 'dart:io';

import 'package:dicoding_story/data/services/api/model/story.dart';
import 'package:dio/dio.dart';

class StoryApi {
  final Dio _dio;
  final String _baseUrl = 'https://story-api.dicoding.dev/v1';

  StoryApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to register');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to login');
    }
  }

  Future<Map<String, dynamic>> addStory(
    String token,
    String description,
    File photo, {
    double? lat,
    double? lon,
  }) async {
    try {
      final formData = FormData.fromMap({
        'description': description,
        'photo': await MultipartFile.fromFile(photo.path),
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
      });

      final response = await _dio.post(
        '$_baseUrl/stories',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add story');
    }
  }

  Future<List<Story>> getAllStories(
    String token, {
    int? page,
    int? size,
    int? location,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/stories',
        queryParameters: {
          if (page != null) 'page': page,
          if (size != null) 'size': size,
          if (location != null) 'location': location,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> listStory = response.data['listStory'];
      return listStory.map((json) => Story.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get all stories',
      );
    }
  }

  Future<Story> getStoryDetail(String token, String id) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/stories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Story.fromJson(response.data['story']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get story detail',
      );
    }
  }
}
