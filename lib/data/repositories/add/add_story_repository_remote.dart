import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/repository/add_story_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:image_picker/image_picker.dart';

class AddStoryRepositoryRemote extends AddStoryRepository {
  final StoryDataSource _storyDataSource;

  AddStoryRepositoryRemote({required StoryDataSource storyDataSource})
    : _storyDataSource = storyDataSource;

  @override
  Future<Either<AppException, DefaultResponse>> addStory(
    String description,
    XFile photoFile, {
    double? lat,
    double? lon,
  }) {
    return _storyDataSource.addStory(
      description,
      photoFile,
      lat: lat,
      lon: lon,
    );
  }
}
