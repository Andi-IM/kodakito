import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/main/view_model/stories_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoriesState', () {
    final tStory = Story(
      id: 'story-1',
      name: 'Story 1',
      description: 'Description 1',
      photoUrl: 'url1',
      createdAt: DateTime.now(),
      lat: 0,
      lon: 0,
    );

    test('initial state is correct', () {
      final state = StoriesState.initial();
      expect(state.stories, isEmpty);
      expect(state.isInitialLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasError, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.nextPage, 1);
      expect(state.sizeItems, 10);
    });

    test('supports value equality', () {
      final state1 = StoriesState.initial();
      final state2 = StoriesState.initial();

      expect(state1, equals(state2));
    });

    test('copyWith updates stories correctly', () {
      final state = StoriesState.initial();
      final newState = state.copyWith(
        stories: [tStory],
        isInitialLoading: false,
      );

      expect(newState.stories, [tStory]);
      expect(newState.isInitialLoading, isFalse);
    });

    test('copyWith updates loading states correctly', () {
      final state = StoriesState.initial();

      final loadingMoreState = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: true,
      );

      expect(loadingMoreState.isInitialLoading, isFalse);
      expect(loadingMoreState.isLoadingMore, isTrue);
    });

    test('copyWith updates error state correctly', () {
      final state = StoriesState.initial();
      final errorState = state.copyWith(
        hasError: true,
        errorMessage: 'Error message',
        isInitialLoading: false,
      );

      expect(errorState.hasError, isTrue);
      expect(errorState.errorMessage, 'Error message');
    });

    test('copyWith updates pagination correctly', () {
      final state = StoriesState.initial();
      final paginatedState = state.copyWith(
        nextPage: 2,
        isInitialLoading: false,
      );

      expect(paginatedState.nextPage, 2);
    });

    test('nextPage null indicates no more pages', () {
      final state = StoriesState.initial().copyWith(
        nextPage: null,
        isInitialLoading: false,
      );

      expect(state.nextPage, isNull);
    });
  });
}
