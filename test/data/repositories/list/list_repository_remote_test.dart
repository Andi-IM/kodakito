import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStoryDataSource extends Mock implements StoryDataSource {}

void main() {
  late ListRepositoryRemote repository;
  late MockStoryDataSource mockStoryDataSource;

  setUp(() {
    mockStoryDataSource = MockStoryDataSource();
    repository = ListRepositoryRemote(storyDataSource: mockStoryDataSource);
  });

  final tStory = Story(
    id: 'story-1',
    name: 'User',
    description: 'Description',
    photoUrl: 'url',
    createdAt: DateTime.now(),
    lat: 0.0,
    lon: 0.0,
  );
  final tStories = [tStory];

  group('getListStories', () {
    test(
      'should return List<Story> when data source returns success',
      () async {
        // Arrange
        when(
          () => mockStoryDataSource.getAllStories(),
        ).thenAnswer((_) async => Right(tStories));

        // Act
        final result = await repository.getListStories();

        // Assert
        verify(() => mockStoryDataSource.getAllStories()).called(1);
        expect(result, Right(tStories));
      },
    );

    test(
      'should return AppException when data source returns failure',
      () async {
        // Arrange
        final tException = AppException(
          message: 'Error',
          statusCode: 500,
          identifier: 'error',
        );
        when(
          () => mockStoryDataSource.getAllStories(),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await repository.getListStories();

        // Assert
        verify(() => mockStoryDataSource.getAllStories()).called(1);
        expect(result, Left(tException));
      },
    );
    test('should return cached data when cache is populated', () async {
      // Arrange
      when(
        () => mockStoryDataSource.getAllStories(),
      ).thenAnswer((_) async => Right(tStories));

      // Act
      await repository.getListStories(); // First call to populate cache
      final result = await repository
          .getListStories(); // Second call should use cache

      // Assert
      verify(() => mockStoryDataSource.getAllStories()).called(1);
      expect(result, Right(tStories));
    });
  });
}
