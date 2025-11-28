import 'package:dicoding_story/data/model/story.dart';
import 'package:dicoding_story/presentation/pages/add_story_page.dart'
    show AddStoryPage;
import 'package:dicoding_story/presentation/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          showDialog(
            context: context,
            builder: (context) {
              if (ResponsiveBreakpoints.of(context).largerThan(MOBILE)) {
                return AlertDialog(
                  title: const Text('AlertDialog Title'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('This is a demo alert dialog.'),
                        Text('Would you like to approve of this message?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Approve'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              } else {
                return Dialog.fullscreen(child: const AddStoryPage());
              }
            },
          );
        },
        tooltip: 'Add Story',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
