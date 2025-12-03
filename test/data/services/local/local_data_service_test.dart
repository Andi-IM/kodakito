import 'dart:convert';
import 'dart:typed_data';

import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDataService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    service = LocalDataService();
  });

  const tStoryJson = {
    "error": false,
    "message": "Stories fetched successfully",
    "listStory": [
      {
        "id": "story-1",
        "name": "User 1",
        "description": "Description 1",
        "photoUrl": "url1",
        "createdAt": "2022-01-01T00:00:00.000Z",
        "lat": 0.0,
        "lon": 0.0,
      },
    ],
  };

  group('getListStories', () {
    test('should return list of stories from assets', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            if (message == null) return null;
            final String key = utf8.decode(message.buffer.asUint8List());
            if (key == 'assets/stories.json') {
              return ByteData.view(
                Uint8List.fromList(utf8.encode(jsonEncode(tStoryJson))).buffer,
              );
            }
            return null;
          });

      // Act
      final result = await service.getListStories();

      // Assert
      expect(result, isA<List<Story>>());
      expect(result.length, 1);
      expect(result.first.id, 'story-1');
    });
  });

  group('getDetailStory', () {
    test('should return story detail by id', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            if (message == null) return null;
            return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(tStoryJson))).buffer,
            );
          });

      await service.getListStories();

      // Act
      final result = service.getDetailStory('story-1');

      // Assert
      expect(result, isA<Story>());
      expect(result.id, 'story-1');
    });
  });

  group('addStory', () {
    test('should add story to the list', () {
      // Arrange
      final tStory = Story(
        id: 'story-2',
        name: 'User 2',
        description: 'Description 2',
        photoUrl: 'url2',
        createdAt: DateTime.now(),
        lat: 0.0,
        lon: 0.0,
      );

      // Act
      service.addStory(tStory);

      // Assert
      final result = service.getDetailStory('story-2');
      expect(result, tStory);
    });
  });
}
