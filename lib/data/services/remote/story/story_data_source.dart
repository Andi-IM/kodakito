import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dio/dio.dart';

abstract class StoryDataSource {
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    File photo, {
    double? lat,
    double? lon,
  });

  Future<Either<AppException, List<Story>>> getAllStories({
    int? page,
    int? size,
    int? location,
  });

  Future<Either<AppException, Story>> getStoryDetail(String id);
}

class StoryRemoteDataSource implements StoryDataSource {
  final NetworkService networkService;

  StoryRemoteDataSource({required this.networkService});

  @override
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    File photo, {
    double? lat,
    double? lon,
  }) async {
    final formData = FormData.fromMap({
      'description': description,
      'photo': await MultipartFile.fromFile(photo.path),
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    });

    final response = await networkService.post('/stories', data: formData);
    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null) {
        return Left(
          AppException(
            identifier: 'postStoryData',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      return Right(DefaultResponse.fromJson(jsonData));
    });
  }

  @override
  Future<Either<AppException, List<Story>>> getAllStories({
    int? page,
    int? size,
    int? location,
  }) async {
    final response = await networkService.get(
      '/stories',
      queryParameters: {
        if (page != null) 'page': page,
        if (size != null) 'size': size,
        if (location != null) 'location': location,
      },
    );

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null) {
        return Left(
          AppException(
            identifier: 'getAllStories',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      return Right(StoryResponse.fromJson(jsonData).listStory);
    });
  }

  @override
  Future<Either<AppException, Story>> getStoryDetail(String id) async {
    final response = await networkService.get('/stories/$id');

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null) {
        return Left(
          AppException(
            identifier: 'getStoryDetail',
            statusCode: 0,
            message: 'The data is not in the valid format.',
          ),
        );
      }
      final story = jsonData['story'];

      return Right(Story.fromJson(story));
    });
  }
}
