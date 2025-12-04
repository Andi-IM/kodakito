import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/models/response.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkService extends Mock implements NetworkService {}

class MockFile extends Mock implements File {}

void main() {
  late StoryRemoteDataSource dataSource;
  late MockNetworkService mockNetworkService;

  setUp(() {
    mockNetworkService = MockNetworkService();
    dataSource = StoryRemoteDataSource(networkService: mockNetworkService);
  });

  group('StoryRemoteDataSource', () {
    final tStory = Story(
      id: 'story-1',
      name: 'User 1',
      description: 'Description 1',
      photoUrl: 'https://example.com/photo.jpg',
      createdAt: DateTime.now(),
      lat: 10.0,
      lon: 10.0,
    );
    final tStoryResponseData = {
      'error': false,
      'message': 'success',
      'listStory': [
        {
          'id': 'story-1',
          'name': 'User 1',
          'description': 'Description 1',
          'photoUrl': 'https://example.com/photo.jpg',
          'createdAt': tStory.createdAt.toIso8601String(),
          'lat': 10.0,
          'lon': 10.0,
        },
      ],
    };
    final tStoryDetailResponseData = {
      'error': false,
      'message': 'success',
      'story': {
        'id': 'story-1',
        'name': 'User 1',
        'description': 'Description 1',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': tStory.createdAt.toIso8601String(),
        'lat': 10.0,
        'lon': 10.0,
      },
    };

    group('getAllStories', () {
      test('should return Right(List<Story>) when successful', () async {
        // Arrange
        when(
          () => mockNetworkService.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async =>
              Response(data: tStoryResponseData, statusCode: 200).toRight,
        );

        // Act
        final result = await dataSource.getAllStories();

        // Assert
        expect(result, isA<Right<AppException, List<Story>>>());
        result.fold((l) => fail('Should not return Left'), (r) {
          expect(r.length, 1);
          expect(r.first.id, tStory.id);
        });
        verify(
          () => mockNetworkService.get('/stories', queryParameters: {}),
        ).called(1);
      });

      test('should call with correct query parameters', () async {
        // Arrange
        when(
          () => mockNetworkService.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async =>
              Response(data: tStoryResponseData, statusCode: 200).toRight,
        );

        // Act
        await dataSource.getAllStories(page: 1, size: 10, location: 1);

        // Assert
        verify(
          () => mockNetworkService.get(
            '/stories',
            queryParameters: {'page': 1, 'size': 10, 'location': 1},
          ),
        ).called(1);
      });

      test('should return Left(AppException) when data is null', () async {
        // Arrange
        when(
          () => mockNetworkService.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(data: null, statusCode: 200).toRight,
        );

        // Act
        final result = await dataSource.getAllStories();

        // Assert
        expect(result, isA<Left<AppException, List<Story>>>());
        result.fold((l) {
          expect(l.message, 'The data is not in the valid format.');
          expect(l.identifier, 'getAllStories');
        }, (r) => fail('Should return Left'));
      });

      test('should return Left(AppException) when failed', () async {
        // Arrange
        final tException = AppException(
          message: 'Error',
          statusCode: 400,
          identifier: 'Error',
        );
        when(
          () => mockNetworkService.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await dataSource.getAllStories();

        // Assert
        expect(result, isA<Left<AppException, List<Story>>>());
        verify(
          () => mockNetworkService.get('/stories', queryParameters: {}),
        ).called(1);
      });
    });

    group('getStoryDetail', () {
      test('should return Right(Story) when successful', () async {
        // Arrange
        when(() => mockNetworkService.get(any())).thenAnswer(
          (_) async =>
              Response(data: tStoryDetailResponseData, statusCode: 200).toRight,
        );

        // Act
        final result = await dataSource.getStoryDetail('story-1');

        // Assert
        expect(result, isA<Right<AppException, Story>>());
        result.fold((l) => fail('Should not return Left'), (r) {
          expect(r.id, tStory.id);
        });
        verify(() => mockNetworkService.get('/stories/story-1')).called(1);
      });

      test('should return Left(AppException) when data is null', () async {
        // Arrange
        when(() => mockNetworkService.get(any())).thenAnswer(
          (_) async => Response(data: null, statusCode: 200).toRight,
        );

        // Act
        final result = await dataSource.getStoryDetail('story-1');

        // Assert
        expect(result, isA<Left<AppException, Story>>());
        result.fold((l) {
          expect(l.message, 'The data is not in the valid format.');
          expect(l.identifier, 'getStoryDetail');
        }, (r) => fail('Should return Left'));
      });

      test('should return Left(AppException) when failed', () async {
        // Arrange
        final tException = AppException(
          message: 'Error',
          statusCode: 400,
          identifier: 'Error',
        );
        when(
          () => mockNetworkService.get(any()),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await dataSource.getStoryDetail('story-1');

        // Assert
        expect(result, isA<Left<AppException, Story>>());
        verify(() => mockNetworkService.get('/stories/story-1')).called(1);
      });
    });

    // Note: addStory test requires File mocking which is complex with MultipartFile.
    // For now, we will skip addStory test or implement a basic one if possible.
    // Since MultipartFile.fromFile is a static method, it's hard to mock without a wrapper or real file.
    // We will try to create a real temp file.
    group('addStory', () {
      late File tFile;

      setUp(() {
        tFile = File('${Directory.systemTemp.path}/test_image.jpg');
        tFile.createSync();
      });

      tearDown(() {
        if (tFile.existsSync()) {
          tFile.deleteSync();
        }
      });

      test('should return Right(Map) when successful', () async {
        // Arrange
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            data: {'error': false, 'message': 'success'},
            statusCode: 201,
          ).toRight,
        );

        // Act
        final result = await dataSource.addStory(
          'Description',
          tFile,
          lat: 10.0,
          lon: 10.0,
        );

        // Assert
        expect(result, isA<Right<AppException, Map<String, dynamic>>>());
        verify(
          () => mockNetworkService.post('/stories', data: any(named: 'data')),
        ).called(1);
      });

      test('should return Left(AppException) when data is null', () async {
        // Arrange
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(data: null, statusCode: 200).toRight,
        );

        // Act
        final result = await dataSource.addStory(
          'Description',
          tFile,
          lat: 10.0,
          lon: 10.0,
        );

        // Assert
        expect(result, isA<Left<AppException, Map<String, dynamic>>>());
        result.fold((l) {
          expect(l.message, 'The data is not in the valid format.');
          expect(l.identifier, 'postStoryData');
        }, (r) => fail('Should return Left'));
      });
    });
  });
}
