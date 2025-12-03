import 'dart:convert';

import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter/services.dart';

class LocalDataService {
  List<Story> _stories = [];

  LocalDataService();

  Future<List<Story>> getListStories() async {
    final localData = await rootBundle.loadString('assets/stories.json');
    final response = StoryResponse.fromJson(jsonDecode(localData));
    _stories = response.listStory;
    return _stories;
  }

  Story getDetailStory(String id) {
    return _stories.firstWhere((element) => element.id == id);
  }

  void addStory(Story story) {
    _stories.add(story);
  }
}
