import 'dart:convert';
import 'dart:io';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDataService service;
  late Directory tempDir;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    service = LocalDataService();
    tempDir = Directory.systemTemp.createTempSync();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
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

  group('loadStories', () {
    test(
      'should load from assets and save to local file when file does not exist',
      () async {
        // Arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              if (message == null) return null;
              final String key = utf8.decode(message.buffer.asUint8List());
              if (key == 'assets/stories.json') {
                return ByteData.view(
                  Uint8List.fromList(
                    utf8.encode(jsonEncode(tStoryJson)),
                  ).buffer,
                );
              }
              return null;
            });

        // Act
        await service.loadStories();

        // Assert
        final localFile = File('${tempDir.path}/stories.json');
        expect(await localFile.exists(), true);
        final content = await localFile.readAsString();
        expect(jsonDecode(content), tStoryJson);
        final stories = await service.getListStories();
        expect(stories.length, 1);
        expect(stories.first.id, 'story-1');
      },
    );

    test('should load from local file when it exists', () async {
      // Arrange
      final localFile = File('${tempDir.path}/stories.json');
      final localStories = {
        "error": false,
        "message": "Stories fetched successfully",
        "listStory": [
          {
            "id": "story-local",
            "name": "User Local",
            "description": "Description Local",
            "photoUrl": "urlLocal",
            "createdAt": "2022-01-01T00:00:00.000Z",
            "lat": 0.0,
            "lon": 0.0,
          },
        ],
      };
      await localFile.writeAsString(jsonEncode(localStories));

      // Act
      await service.loadStories();

      // Assert
      final stories = await service.getListStories();
      expect(stories.length, 1);
      expect(stories.first.id, 'story-local');
    });

    test('should throw exception and reset loading future on error', () async {
      // Arrange
      final localFile = File('${tempDir.path}/stories.json');
      await localFile.writeAsString('invalid json');

      // Act & Assert
      await expectLater(
        () => service.loadStories(),
        throwsA(isA<FormatException>()),
      );
    });
  });

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
      final result = await service.getDetailStory('story-1');

      // Assert
      expect(result, isA<Story>());
      expect(result.id, 'story-1');
    });

    test('should throw StateError when story id is not found', () async {
      // Arrange
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            if (message == null) return null;
            return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(tStoryJson))).buffer,
            );
          });

      await service.getListStories();

      // Act & Assert
      expect(
        () => service.getDetailStory('non-existent-id'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Story with id "non-existent-id" not found',
          ),
        ),
      );
    });
  });

  group('addStory', () {
    test('should add story to the list', () async {
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
      await service.addStory(tStory);

      // Assert
      final result = await service.getDetailStory('story-2');
      expect(result, tStory);
    });
  });
}
