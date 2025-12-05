import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStoryDataSource extends Mock implements StoryDataSource {}

class FakeStory extends Fake implements Story {}

void main() {
  late ListRepositoryRemote repository;
  late MockStoryDataSource mockStoryDataSource;

  setUpAll(() {
    registerFallbackValue(FakeStory());
  });

  setUp(() {
    mockStoryDataSource = MockStoryDataSource();
    repository = ListRepositoryRemote(storyDataSource: mockStoryDataSource);
  });

  group('ListRepositoryRemote', () {
    final tStories = [
      Story(
        id: '1',
        name: 'Story 1',
        description: 'Description 1',
        photoUrl: 'url1',
        createdAt: DateTime.now(),
        lat: null,
        lon: null,
      ),
    ];

    test('should implement CacheInterface', () {
      expect(repository, isA<CacheInterface>());
    });

    test(
      'should return Right(List<Story>) when getListStories is successful',
      () async {
        // arrange
        when(
          () => mockStoryDataSource.getAllStories(),
        ).thenAnswer((_) async => Right(tStories));

        // act
        final result = await repository.getListStories();

        // assert
        expect(result, Right(tStories));
        verify(() => mockStoryDataSource.getAllStories()).called(1);
      },
    );

    test('should return cached stories on subsequent calls', () async {
      // arrange
      when(
        () => mockStoryDataSource.getAllStories(),
      ).thenAnswer((_) async => Right(tStories));

      // act
      await repository.getListStories();
      final result = await repository.getListStories();

      // assert
      expect(result, Right(tStories));
      verify(() => mockStoryDataSource.getAllStories()).called(1);
    });

    test(
      'should return Left(AppException) when getListStories fails',
      () async {
        // arrange
        final tException = AppException(
          message: 'error',
          statusCode: 500,
          identifier: 'test',
        );
        when(
          () => mockStoryDataSource.getAllStories(),
        ).thenAnswer((_) async => Left(tException));

        // act
        final result = await repository.getListStories();

        // assert
        expect(result, Left(tException));
        verify(() => mockStoryDataSource.getAllStories()).called(1);
      },
    );

    test('should invalidate cache', () async {
      // arrange
      when(
        () => mockStoryDataSource.getAllStories(),
      ).thenAnswer((_) async => Right(tStories));

      // act
      await repository.getListStories();
      repository.invalidateCache();
      await repository.getListStories();

      // assert
      verify(() => mockStoryDataSource.getAllStories()).called(2);
    });
  });
}
