import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoryState', () {
    final tStory = Story(
      id: '1',
      name: 'Test Story',
      description: 'Description',
      photoUrl: 'url',
      createdAt: DateTime(2022, 1, 1),
      lat: 0.0,
      lon: 0.0,
    );

    test('supports value equality', () {
      expect(const StoryState.initial(), const StoryState.initial());
    });

    test('initial state is correct', () {
      const state = StoryState.initial();
      expect(state.state, StoryStateType.initial);
      expect(state.story, null);
      expect(state.errorMessage, null);
    });

    test('copyWith returns a new instance with updated values', () {
      const state = StoryState.initial();
      final newState = state.copyWith(
        state: StoryStateType.loaded,
        story: tStory,
        errorMessage: 'error',
      );

      expect(newState.state, StoryStateType.loaded);
      expect(newState.story, tStory);
      expect(newState.errorMessage, 'error');
    });

    test('copyWith returns the same instance if no values are passed', () {
      const state = StoryState.initial();
      final newState = state.copyWith();

      expect(newState, state);
    });

    test('props are correct', () {
      const state = StoryState(
        state: StoryStateType.loaded,
        story: null,
        errorMessage: 'error',
      );

      expect(state.props, [null, StoryStateType.loaded, 'error']);
    });

    test('toString returns correct string representation', () {
      const state = StoryState(
        state: StoryStateType.initial,
        story: null,
        errorMessage: null,
      );

      expect(
        state.toString(),
        'StoryState(story: null, state: StoryStateType.initial, errorMessage: null)',
      );
    });
  });
}
