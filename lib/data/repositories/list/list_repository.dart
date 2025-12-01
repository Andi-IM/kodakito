

/// Data source for list of stories
abstract class ListRepository {
  /// Get list of stories
  Future<List<Story>> getListStories();
}