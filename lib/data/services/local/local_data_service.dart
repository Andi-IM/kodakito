import 'dart:convert';
import 'dart:io';

import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class LocalDataService {
  List<Story> _stories = [];
  Future<void>? _loadingFuture;

  /// Gets the path to the local stories file in app documents directory
  Future<String> get _localFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/stories.json';
  }

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
      final localPath = await _localFilePath;
      final localFile = File(localPath);

      String jsonData;

      // Check if local file exists, otherwise load from assets
      if (await localFile.exists()) {
        jsonData = await localFile.readAsString();
      } else {
        // First time: load from assets and save to local file
        jsonData = await rootBundle.loadString('assets/stories.json');
        await localFile.writeAsString(jsonData);
      }

      final response = StoryResponse.fromJson(jsonDecode(jsonData));
      // Create a modifiable copy of the list
      _stories = List.from(response.listStory);
    } catch (e) {
      // Reset loading future on error so it can be retried
      _loadingFuture = null;
      rethrow;
    }
  }

  /// Saves the current stories list to local storage
  Future<void> _saveStories() async {
    final localPath = await _localFilePath;
    final localFile = File(localPath);

    final response = StoryResponse(
      error: false,
      message: 'Stories saved successfully',
      listStory: _stories,
    );

    final jsonData = jsonEncode(response.toJson());
    await localFile.writeAsString(jsonData);
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
    // Persist to local storage
    await _saveStories();
  }
}
