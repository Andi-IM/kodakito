import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_remote.dart';
import 'package:dicoding_story/data/services/api/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStoryDataSource extends Mock implements StoryDataSource {}

void main() {
  late DetailRepositoryRemote repository;
  late MockStoryDataSource mockStoryDataSource;

  setUp(() {
    mockStoryDataSource = MockStoryDataSource();
    repository = DetailRepositoryRemote(storyDataSource: mockStoryDataSource);
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

  group('getDetailStory', () {
    test('should return Story when data source returns success', () async {
      // Arrange
      when(
        () => mockStoryDataSource.getStoryDetail(any()),
      ).thenAnswer((_) async => Right(tStory));

      // Act
      final result = await repository.getDetailStory('story-1');

      // Assert
      verify(() => mockStoryDataSource.getStoryDetail('story-1')).called(1);
      expect(result, Right(tStory));
    });

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
          () => mockStoryDataSource.getStoryDetail(any()),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await repository.getDetailStory('story-1');

        // Assert
        verify(() => mockStoryDataSource.getStoryDetail('story-1')).called(1);
        expect(result, Left(tException));
      },
    );
  });
}
