import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';

/// Remote data source for [Story].
class ListRepositoryRemote implements ListRepository {
  final StoryDataSource _storyDataSource;

  ListRepositoryRemote({required StoryDataSource storyDataSource})
    : _storyDataSource = storyDataSource;


  @override
  Future<Either<AppException, List<Story>>> getListStories() async {
    return await _storyDataSource.getAllStories();
  }

}
