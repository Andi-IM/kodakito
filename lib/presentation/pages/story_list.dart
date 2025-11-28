import 'package:dicoding_story/data/model/story.dart';
import 'package:dicoding_story/presentation/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StoryListPage extends StatefulWidget {
  const StoryListPage({super.key, required this.title});
  final String title;

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Story> _dummyStories = [
    Story(
      id: '1',
      name: 'Dimas',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s.',
      photoUrl: 'https://picsum.photos/id/237/400/200',
      createdAt: DateTime.now(),
    ),
    Story(
      id: '2',
      name: 'Arif',
      description:
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.',
      photoUrl: 'https://picsum.photos/id/238/400/200',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Story(
      id: '3',
      name: 'Fikri',
      description:
          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.',
      photoUrl: 'https://picsum.photos/id/239/400/200',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'KodaKito',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _dummyStories.length,
          itemBuilder: (context, index) {
            final story = _dummyStories[index];
            return StoryCard(
              story: story,
              onTap: () {
                context.push('/story_detail', extra: story);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add story page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Story feature coming soon!')),
          );
        },
        tooltip: 'Add Story',
        child: const Icon(Icons.add),
      ),
    );
  }
}
