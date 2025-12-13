import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';

/// Data source for list of stories
abstract class ListRepository {
  /// Get list of stories with pagination support
  Future<Either<AppException, List<Story>>> getListStories({
    int page = 1,
    int size = 10,
  });
}
