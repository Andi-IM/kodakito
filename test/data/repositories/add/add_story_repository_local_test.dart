import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/add/add_story_repository_local.dart';
import 'package:dicoding_story/data/services/local/local_data_service.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDataService extends Mock implements LocalDataService {}

class FakeStory extends Fake implements Story {}

void main() {
  late AddStoryRepositoryLocal repository;
  late MockLocalDataService mockLocalDataService;

  setUpAll(() {
    registerFallbackValue(FakeStory());
  });

  setUp(() {
    mockLocalDataService = MockLocalDataService();
    repository = AddStoryRepositoryLocal(
      localDataService: mockLocalDataService,
    );
  });

  group('AddStoryRepositoryLocal', () {
    final tDescription = 'test description';
    final tFile = XFile('test_path');
    final tLat = 10.0;
    final tLon = 10.0;

    test(
      'should return Right(DefaultResponse) when addStory is successful',
      () async {
        // arrange
        when(
          () => mockLocalDataService.addStory(any()),
        ).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.addStory(
          tDescription,
          tFile,
          lat: tLat,
          lon: tLon,
        );

        // assert
        expect(result, isA<Right<AppException, DefaultResponse>>());
        verify(() => mockLocalDataService.addStory(any())).called(1);
      },
    );

    test(
      'should return Left(AppException) when addStory throws an exception',
      () async {
        // arrange
        when(
          () => mockLocalDataService.addStory(any()),
        ).thenThrow(Exception('test error'));

        // act
        final result = await repository.addStory(
          tDescription,
          tFile,
          lat: tLat,
          lon: tLon,
        );

        // assert
        expect(result, isA<Left<AppException, DefaultResponse>>());
        result.fold(
          (l) => expect(l.message, 'Exception: test error'),
          (r) => fail('Should return Left'),
        );
        verify(() => mockLocalDataService.addStory(any())).called(1);
      },
    );
  });
}
