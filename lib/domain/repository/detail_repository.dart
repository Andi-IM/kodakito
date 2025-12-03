import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart' show AppException;

/// Data source for list of stories
abstract class DetailRepository {
  /// Get list of stories
  Future<Either<AppException, Story>> getDetailStory(String id);
}
