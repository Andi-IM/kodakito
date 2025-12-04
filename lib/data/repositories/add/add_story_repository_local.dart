import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:uuid/uuid.dart';

class AddStoryRepositoryLocal extends AddStoryRepository {
  final LocalDataService _localDataService;

  AddStoryRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  @override
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    File photo, {
    double? lat,
    double? lon,
  }) {
    try {
      _localDataService.addStory(
        Story(
          id: Uuid().v4(),
          name: 'Andi Irham',
          description: description,
          photoUrl:
              'https://cdn0-production-images-kly.akamaized.net/7u_FXVyv4CdFdIBlp9BLNwkMcD8=/1200x675/smart/filters:quality(75):strip_icc():format(jpeg)/kly-media-production/medias/1152505/original/082492200_1456312684-singkarak.jpg',
          createdAt: DateTime.now(),
          lat: lat,
          lon: lon,
        ),
      );
      return Future.value(Right(DefaultResponse(error: false, message: '')));
    } catch (e) {
      return Future.value(
        Left(
          AppException(
            message: e.toString(),
            statusCode: 500,
            identifier: 'addStory',
          ),
        ),
      );
    }
  }
}
