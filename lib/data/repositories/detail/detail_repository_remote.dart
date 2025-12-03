import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class DetailRepositoryRemote implements DetailRepository {
  final StoryDataSource _storyDataSource;

  DetailRepositoryRemote({required StoryDataSource storyDataSource})
    : _storyDataSource = storyDataSource;

  @override
  Future<Either<AppException, Story>> getDetailStory(String id) async {
    final result = await _storyDataSource.getStoryDetail(id);
    return result;
  }
}
