import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_compact_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

void main() {
  testWidgets('story detail compact layout renders correctly', (tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoryDetailCompactLayout(
              colorScheme: const ColorScheme.light(),
              story: Story(
                id: 'id-test1',
                name: 'Andi Irham',
                photoUrl: 'https://picsum.photos/200/300',
                description:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                createdAt: DateTime.now(),
                lat: null,
                lon: null,
              ),
            ),
          ),
        ),
      );
    });

    final herokey = ValueKey('image_id-test1');
    final avatarkey = ValueKey('avatar_id-test1');
    final namekey = ValueKey('name_id-test1');
    final descriptionkey = ValueKey('description_id-test1');

    // expect
    expect(find.byKey(herokey), findsOneWidget);
    expect(find.byKey(avatarkey), findsOneWidget);
    expect(find.byKey(namekey), findsOneWidget);
    expect(find.byKey(descriptionkey), findsOneWidget);
  });
}
