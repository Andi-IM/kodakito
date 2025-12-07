import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/add/add_story_repository_remote.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/story/story_data_source.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockStoryDataSource extends Mock implements StoryDataSource {}

class FakeXFile extends Fake implements XFile {}

void main() {
  late AddStoryRepositoryRemote repository;
  late MockStoryDataSource mockStoryDataSource;

  setUpAll(() {
    registerFallbackValue(FakeXFile());
  });

  setUp(() {
    mockStoryDataSource = MockStoryDataSource();
    repository = AddStoryRepositoryRemote(storyDataSource: mockStoryDataSource);
  });

  group('AddStoryRepositoryRemote', () {
    final tDescription = 'test description';
    final tFile = XFile('test_path');
    final tLat = 10.0;
    final tLon = 10.0;
    final tResponse = DefaultResponse(error: false, message: 'success');

    test(
      'should return Right(DefaultResponse) when addStory is successful',
      () async {
        // arrange
        when(
          () => mockStoryDataSource.addStory(
            any(),
            any(),
            lat: any(named: 'lat'),
            lon: any(named: 'lon'),
          ),
        ).thenAnswer((_) async => Right(tResponse));

        // act
        final result = await repository.addStory(
          tDescription,
          tFile,
          lat: tLat,
          lon: tLon,
        );

        // assert
        expect(result, Right(tResponse));
        verify(
          () => mockStoryDataSource.addStory(
            tDescription,
            tFile,
            lat: tLat,
            lon: tLon,
          ),
        ).called(1);
      },
    );

    test('should return Left(AppException) when addStory fails', () async {
      // arrange
      final tException = AppException(
        message: 'error',
        statusCode: 500,
        identifier: 'test',
      );
      when(
        () => mockStoryDataSource.addStory(
          any(),
          any(),
          lat: any(named: 'lat'),
          lon: any(named: 'lon'),
        ),
      ).thenAnswer((_) async => Left(tException));

      // act
      final result = await repository.addStory(
        tDescription,
        tFile,
        lat: tLat,
        lon: tLon,
      );

      // assert
      expect(result, Left(tException));
      verify(
        () => mockStoryDataSource.addStory(
          tDescription,
          tFile,
          lat: tLat,
          lon: tLon,
        ),
      ).called(1);
    });
  });
}
