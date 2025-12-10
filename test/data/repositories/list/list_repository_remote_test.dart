import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_remote.dart';
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

    test(
      'should return Right(List<Story>) when getListStories is successful',
      () async {
        // arrange
        when(
          () => mockStoryDataSource.getAllStories(
            page: any(named: 'page'),
            size: any(named: 'size'),
            location: any(named: 'location'),
          ),
        ).thenAnswer((_) async => Right(tStories));

        // act
        final result = await repository.getListStories();

        // assert
        expect(result, Right(tStories));
        verify(
          () => mockStoryDataSource.getAllStories(
            page: any(named: 'page'),
            size: any(named: 'size'),
            location: any(named: 'location'),
          ),
        ).called(1);
      },
    );

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
          () => mockStoryDataSource.getAllStories(
            page: any(named: 'page'),
            size: any(named: 'size'),
            location: any(named: 'location'),
          ),
        ).thenAnswer((_) async => Left(tException));

        // act
        final result = await repository.getListStories();

        // assert
        expect(result, Left(tException));
        verify(
          () => mockStoryDataSource.getAllStories(
            page: any(named: 'page'),
            size: any(named: 'size'),
            location: any(named: 'location'),
          ),
        ).called(1);
      },
    );
  });
}
