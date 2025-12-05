import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';

/// Data source for list of stories
abstract class ListRepository {
  /// Get list of stories
  Future<Either<AppException, List<Story>>> getListStories();
}

abstract class ListRepositoryRemote extends ListRepository {
  @override
  Future<Either<AppException, List<Story>>> getListStories();

  void invalidateCache();
}
