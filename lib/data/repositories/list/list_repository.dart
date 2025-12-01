import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/result.dart';

/// Data source for list of stories
abstract class ListRepository {
  /// Get list of stories
  Future<Result<List<Story>>> getListStories();
}
