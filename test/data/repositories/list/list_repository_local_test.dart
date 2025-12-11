import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/list/list_repository_local.dart';
import 'package:dicoding_story/data/services/api/local/local_data_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDataService extends Mock implements LocalDataService {}

void main() {
  late ListRepositoryLocal repository;
  late MockLocalDataService mockLocalDataService;

  setUp(() {
    mockLocalDataService = MockLocalDataService();
    repository = ListRepositoryLocal(localDataService: mockLocalDataService);
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
      'should return List<Story> when local data service returns data',
      () async {
        // Arrange
        when(
          () => mockLocalDataService.getListStories(),
        ).thenAnswer((_) async => tStories);

        // Act
        final result = await repository.getListStories();

        // Assert
        verify(() => mockLocalDataService.getListStories()).called(1);
        expect(result, Right(tStories));
      },
    );

    test(
      'should return AppException when local data service throws exception',
      () async {
        // Arrange
        when(
          () => mockLocalDataService.getListStories(),
        ).thenThrow(Exception('Error'));

        // Act
        final result = await repository.getListStories();

        // Assert
        verify(() => mockLocalDataService.getListStories()).called(1);
        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, isA<AppException>());
          expect(l.message, 'Exception: Error');
          expect(l.statusCode, 500);
        }, (r) => fail('Should return Left'));
      },
    );
  });
}
