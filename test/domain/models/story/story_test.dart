import 'dart:convert';

import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Story', () {
    test('toJson should return a valid map', () {
      // Arrange
      final date = DateTime.parse('2022-01-01T00:00:00.000Z');
      final model = Story(
        id: 'story-id',
        name: 'User Name',
        description: 'Description',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: date,
        lat: 12.5,
        lon: 10.5,
      );
      final expectedJson = {
        'id': 'story-id',
        'name': 'User Name',
        'description': 'Description',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': date.toIso8601String(),
        'lat': 12.5,
        'lon': 10.5,
      };

      // Act
      final result = model.toJson();
      final jsonString = json.encode(result);
      final decoded = json.decode(jsonString);

      // Assert
      expect(decoded, expectedJson);
    });

    test('toJson should handle null lat/lon', () {
      // Arrange
      final date = DateTime.parse('2022-01-01T00:00:00.000Z');
      final model = Story(
        id: 'story-id',
        name: 'User Name',
        description: 'Description',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: date,
        lat: null,
        lon: null,
      );
      final expectedJson = {
        'id': 'story-id',
        'name': 'User Name',
        'description': 'Description',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': date.toIso8601String(),
        'lat': null,
        'lon': null,
      };

      // Act
      final result = model.toJson();
      final jsonString = json.encode(result);
      final decoded = json.decode(jsonString);

      // Assert
      expect(decoded, expectedJson);
    });
  });

  group('StoryResponse', () {
    test('toJson should return a valid map', () {
      // Arrange
      final date = DateTime.parse('2022-01-01T00:00:00.000Z');
      final story = Story(
        id: 'story-id',
        name: 'User Name',
        description: 'Description',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: date,
        lat: 12.5,
        lon: 10.5,
      );
      final model = StoryResponse(
        error: false,
        message: 'success',
        listStory: [story],
      );
      final expectedJson = {
        'error': false,
        'message': 'success',
        'listStory': [
          {
            'id': 'story-id',
            'name': 'User Name',
            'description': 'Description',
            'photoUrl': 'https://example.com/photo.jpg',
            'createdAt': date.toIso8601String(),
            'lat': 12.5,
            'lon': 10.5,
          },
        ],
      };

      // Act
      final result = model.toJson();
      final jsonString = json.encode(result);
      final decoded = json.decode(jsonString);

      // Assert
      expect(decoded, expectedJson);
    });
  });
}
