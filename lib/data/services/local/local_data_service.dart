import 'dart:convert';

import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter/services.dart';

class LocalDataService {
  List<Story> _stories = [];
  Future<void>? _loadingFuture;

  /// Ensures stories are loaded. Only loads once, subsequent calls return the same future.
  Future<void> _ensureLoaded() async {
    // If already loading or loaded, return existing future or complete immediately
    if (_loadingFuture != null) {
      return _loadingFuture;
    }

    if (_stories.isNotEmpty) {
      return;
    }

    // Start loading and cache the future
    _loadingFuture = _loadStories();
    return _loadingFuture;
  }

  Future<void> _loadStories() async {
    try {
      final localData = await rootBundle.loadString('assets/stories.json');
      final response = StoryResponse.fromJson(jsonDecode(localData));
      // Create a modifiable copy of the list
      _stories = List.from(response.listStory);
    } catch (e) {
      // Reset loading future on error so it can be retried
      _loadingFuture = null;
      rethrow;
    }
  }

  Future<List<Story>> getListStories() async {
    await _ensureLoaded();
    return _stories;
  }

  Future<Story> getDetailStory(String id) async {
    await _ensureLoaded();
    return _stories.firstWhere(
      (element) => element.id == id,
      orElse: () => throw StateError('Story with id "$id" not found'),
    );
  }

  Future<void> addStory(Story story) async {
    await _ensureLoaded();
    _stories.add(story);
  }
}
