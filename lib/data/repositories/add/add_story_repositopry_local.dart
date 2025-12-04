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
              'https://awsimages.detik.net.id/community/media/visual/2025/11/28/presiden-ke-ri-joko-widodo-di-rumahnya-di-sumber-banjarsari-solo-jumat-28112025-1764314423059_169.jpeg?w=600&q=90',
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
