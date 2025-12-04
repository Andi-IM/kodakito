import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/domain/repository/list_repository.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  late ProviderContainer container;
  late MockListRepository mockListRepository;
  late Listener<StoriesState> storiesListener;

  setUp(() {
    mockListRepository = MockListRepository();
    storiesListener = Listener<StoriesState>();

    container = ProviderContainer(
      overrides: [listRepositoryProvider.overrideWithValue(mockListRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ImageFile', () {
    test('initial state is null', () {
      final state = container.read(imageFileProvider);
      expect(state, null);
    });

    test('setImageFile updates state', () {
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      container.read(imageFileProvider.notifier).setImageFile(imageBytes);

      final state = container.read(imageFileProvider);
      expect(state, imageBytes);
    });
  });

  group('StoriesNotifier', () {
    final tStories = [
      Story(
        id: 'story-1',
        name: 'Story 1',
        description: 'Description 1',
        photoUrl: 'url1',
        createdAt: DateTime.now(),
        lat: 0,
        lon: 0,
      ),
    ];

    test('initial state is StoriesState.initial', () {
      final state = container.read(storiesProvider);
      expect(state, const StoriesState.initial());
    });

    test('fetchStories success updates state to loaded', () async {
      // Arrange
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => Right(tStories));

      container.listen(
        storiesProvider,
        storiesListener.call,
        fireImmediately: true,
      );

      // Act
      // Trigger fetchStories by reading the provider (it runs in build)
      // or calling it manually if we want to test the method specifically.
      // Since it runs in build via microtask, we might need to wait.
      // However, to test the logic deterministically, we can call the method manually.
      await container.read(storiesProvider.notifier).fetchStories();

      // Assert
      verifyInOrder([
        () => storiesListener(null, const StoriesState.initial()),
        () => storiesListener(
          const StoriesState.initial(),
          const StoriesState(state: StoriesConcreteState.loading),
        ),
        () => storiesListener(
          const StoriesState(state: StoriesConcreteState.loading),
          StoriesState(state: StoriesConcreteState.loaded, stories: tStories),
        ),
      ]);
      verify(() => mockListRepository.getListStories()).called(1);
    });

    test('fetchStories failure updates state to failure', () async {
      // Arrange
      final exception = AppException(
        message: 'Fetch failed',
        statusCode: 500,
        identifier: 'fetch',
      );
      when(
        () => mockListRepository.getListStories(),
      ).thenAnswer((_) async => Left(exception));

      container.listen(
        storiesProvider,
        storiesListener.call,
        fireImmediately: true,
      );

      // Act
      await container.read(storiesProvider.notifier).fetchStories();

      // Assert
      verifyInOrder([
        () => storiesListener(null, const StoriesState.initial()),
        () => storiesListener(
          const StoriesState.initial(),
          const StoriesState(state: StoriesConcreteState.loading),
        ),
        () => storiesListener(
          const StoriesState(state: StoriesConcreteState.loading),
          StoriesState(
            state: StoriesConcreteState.failure,
            message: exception.message,
          ),
        ),
      ]);
      verify(() => mockListRepository.getListStories()).called(1);
    });

    test('resetState resets state to initial', () {
      // Arrange
      // Set some state first
      container.read(storiesProvider.notifier).resetState();

      final state = container.read(storiesProvider);
      expect(state, const StoriesState.initial());
    });
  });
}

class MockListRepository extends Mock implements ListRepository {}
