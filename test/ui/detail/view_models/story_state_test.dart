import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart' as st;
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

    test('Initial can be created', () {
      const state = st.Initial();
      expect(state, isA<st.Initial>());
    });

    test('Loading can be created', () {
      const state = st.Loading();
      expect(state, isA<st.Loading>());
    });

    test('Loaded holds correct story', () {
      final state = st.Loaded(story: tStory, imageBytes: null);
      expect(state, isA<st.Loaded>());
      expect(state.story, tStory);
    });

    test('Error holds correct errorMessage', () {
      const state = st.Error(errorMessage: 'error');
      expect(state, isA<st.Error>());
      expect(state.errorMessage, 'error');
    });
  });
}
