import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/detail/detail_repository_local.dart';
import 'package:dicoding_story/data/services/api/local/local_data_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDataService extends Mock implements LocalDataService {}

void main() {
  late DetailRepositoryLocal repository;
  late MockLocalDataService mockLocalDataService;

  setUp(() {
    mockLocalDataService = MockLocalDataService();
    repository = DetailRepositoryLocal(localDataService: mockLocalDataService);
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
    test('should return Story when local data service returns data', () async {
      // Arrange
      when(
        () => mockLocalDataService.getDetailStory(any()),
      ).thenAnswer((_) async => tStory);

      // Act
      final result = await repository.getDetailStory('story-1');

      // Assert
      verify(() => mockLocalDataService.getDetailStory('story-1')).called(1);
      expect(result, Right(tStory));
    });
  });
}
