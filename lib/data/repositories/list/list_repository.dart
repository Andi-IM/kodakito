import 'package:dicoding_story/data/services/api/model/story.dart' show Story;

/// Data source for list of stories
abstract class ListRepository {
  /// Get list of stories
  Future<List<Story>> getListStories();
}
