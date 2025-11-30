import 'package:dicoding_story/presentation/main/add_story_modal.dart';
import 'package:dicoding_story/presentation/main/provider/main_provider.dart';
import 'package:dicoding_story/presentation/main/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_size_classes/window_size_classes.dart';
import 'package:m3e_collection/m3e_collection.dart';

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
    final isMedium = widthClass >= WindowWidthClass.medium;
    final stories = ref.watch(mainScreenContentProvider);
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBarM3E(
              shapeFamily: AppBarM3EShapeFamily.square,
              variant: AppBarM3EVariant.small,
              density: AppBarM3EDensity.regular,
              titleText: 'KodaKito',
              centerTitle: !isMedium,
              pinned: false,
            ),
            if (widthClass >= WindowWidthClass.medium)
              SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 400,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
                    story: story,
                    onTap: () => context.go('/story/${story.id}'),
                  );
                },
              )
            else
              SliverList.builder(
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return StoryCard(
                    story: story,
                    onTap: () => context.go('/story/${story.id}'),
                  );
                },
              ),
          ],
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
