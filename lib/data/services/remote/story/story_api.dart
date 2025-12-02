import 'dart:io';

import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/result.dart';
import 'package:dio/dio.dart';

typedef AuthHeaderProvider = String? Function();

class StoryApi {
  final Dio _dio;
  final String _baseUrl = 'https://story-api.dicoding.dev/v1';
  AuthHeaderProvider? authHeaderProvider;

  StoryApi({Dio? dio, this.authHeaderProvider}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authHeaderProvider?.call();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> addStory(
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
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add story');
    }
  }

  Future<Result<List<Story>>> getAllStories({
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
      );

      final List<dynamic> listStory = response.data['listStory'];
      return Ok(listStory.map((json) => Story.fromJson(json)).toList());
    } on DioException catch (e) {
      return Error(
        Exception(e.response?.data['message'] ?? 'Failed to get all stories'),
      );
    }
  }

  Future<Story> getStoryDetail(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/stories/$id');

      return Story.fromJson(response.data['story']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get story detail',
      );
    }
  }
}
