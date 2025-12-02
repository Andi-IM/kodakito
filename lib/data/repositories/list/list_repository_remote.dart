import 'package:dicoding_story/data/repositories/list/list_repository.dart';
import 'package:dicoding_story/data/services/remote/story/story_api.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/result.dart';

/// Remote data source for [Story].
class ListRepositoryRemote implements ListRepository {
  ListRepositoryRemote({required StoryApi storyApi}) : _storyApi = storyApi;

  final StoryApi _storyApi;

  List<Story>? _cachedListStories;

  @override
  Future<Result<List<Story>>> getListStories() async {
    if (_cachedListStories == null) {
      // No cache, fetch from remote
      final result = await _storyApi.getAllStories();
      if (result is Ok<List<Story>>) {
        // Cache the result
        _cachedListStories = result.value;
      }
      return result;
    } else {
      // Cache hit, return cached result
      return Ok(_cachedListStories!);
    }
  }
}
