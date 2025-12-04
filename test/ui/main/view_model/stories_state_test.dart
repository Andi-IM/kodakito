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
      const state = StoriesState.initial();
      expect(state.state, StoriesConcreteState.initial);
      expect(state.stories, isEmpty);
      expect(state.message, isNull);
    });

    test('supports value equality', () {
      const state1 = StoriesState(state: StoriesConcreteState.initial);
      const state2 = StoriesState(state: StoriesConcreteState.initial);
      const state3 = StoriesState(state: StoriesConcreteState.loading);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('copyWith updates state correctly', () {
      const state = StoriesState.initial();
      final newState = state.copyWith(
        state: StoriesConcreteState.loaded,
        stories: [tStory],
        message: 'Success',
      );

      expect(newState.state, StoriesConcreteState.loaded);
      expect(newState.stories, [tStory]);
      expect(newState.message, 'Success');
    });

    test('copyWith with null values retains old values', () {
      final state = StoriesState(
        state: StoriesConcreteState.loaded,
        stories: [tStory],
        message: 'Success',
      );

      final newState = state.copyWith();

      expect(newState.state, state.state);
      expect(newState.stories, state.stories);
      expect(newState.message, state.message);
    });

    test('toString returns correct string representation', () {
      const state = StoriesState.initial();
      expect(
        state.toString(),
        'StoriesState(state: StoriesConcreteState.initial, stories: [], message: null)',
      );
    });

    group('when', () {
      test('returns loading when state is initial', () {
        const state = StoriesState.initial();
        final result = state.when(
          data: (_) => 'data',
          loading: () => 'loading',
          error: (_, __) => 'error',
        );
        expect(result, 'loading');
      });

      test('returns loading when state is loading', () {
        const state = StoriesState(state: StoriesConcreteState.loading);
        final result = state.when(
          data: (_) => 'data',
          loading: () => 'loading',
          error: (_, __) => 'error',
        );
        expect(result, 'loading');
      });

      test('returns data when state is loaded', () {
        final state = StoriesState(
          state: StoriesConcreteState.loaded,
          stories: [tStory],
        );
        final result = state.when(
          data: (stories) => stories,
          loading: () => [],
          error: (_, __) => [],
        );
        expect(result, [tStory]);
      });

      test('returns error when state is failure', () {
        const state = StoriesState(
          state: StoriesConcreteState.failure,
          message: 'Error message',
        );
        final result = state.when(
          data: (_) => 'data',
          loading: () => 'loading',
          error: (msg, _) => msg,
        );
        expect(result, 'Error message');
      });
    });
  });
}
