import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/detail_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class DetailRepositoryLocal implements DetailRepository {
  DetailRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Either<AppException, Story>> getDetailStory(String id) async {
    await Future.delayed(const Duration(seconds: 2));
    final story = await _localDataService.getDetailStory(id);
    return Right(story);
  }
}
