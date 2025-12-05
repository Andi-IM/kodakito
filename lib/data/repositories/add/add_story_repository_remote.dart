import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class AddStoryRepositoryRemote extends AddStoryRepository {
  final StoryDataSource _storyDataSource;
  final CacheInterface? _cacheInterface;

  AddStoryRepositoryRemote({
    required StoryDataSource storyDataSource,
    CacheInterface? cacheInterface,
  }) : _storyDataSource = storyDataSource,
       _cacheInterface = cacheInterface;

  @override
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    File photo, {
    double? lat,
    double? lon,
  }) {
    final result = _storyDataSource.addStory(
      description,
      photo,
      lat: lat,
      lon: lon,
    );
    _cacheInterface?.invalidateCache();
    return result;
  }
}
