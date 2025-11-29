import 'package:dicoding_story/presentation/main/provider/main_provider.dart';
import 'package:dicoding_story/presentation/main/add_story_modal.dart';
import 'package:dicoding_story/presentation/main/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_size_classes/window_size_classes.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthClass = WindowWidthClass.of(context);
    final stories = ref.watch(mainScreenContentProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KodaKito',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: widthClass >= WindowWidthClass.medium ? false : true,
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: Builder(
          builder: (context) {
            final Widget scrollableWidget;
            Widget itemBuilder(BuildContext context, int index) {
              final story = stories[index];
              return StoryCard(
                story: story,
                onTap: () => context.push('/${story.id}'),
              );
            }

            if (widthClass >= WindowWidthClass.medium) {
              scrollableWidget = GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: stories.length,
                itemBuilder: itemBuilder,
              );
            } else {
              scrollableWidget = ListView.builder(
                controller: _scrollController,
                itemCount: stories.length,
                itemBuilder: itemBuilder,
              );
            }
            return scrollableWidget;
          },
        ),
      ),
      floatingActionButton: widthClass >= WindowWidthClass.medium
          ? null
          : _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton({double? elevation}) {
    return FloatingActionButton(
      elevation: elevation,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog.fullscreen(child: const AddStoryPage());
          },
        );
      },
      tooltip: 'Add Story',
      child: const Icon(Icons.add),
    );
  }
}
