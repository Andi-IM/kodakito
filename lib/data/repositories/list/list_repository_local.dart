import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dartz/dartz.dart';

/// Local data source with all possible stories
class ListRepositoryLocal implements ListRepository {
  ListRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Either<AppException, List<Story>>> getListStories() {
    return Future.value(Right(_localDataService.getListStories()));
  }
}
