import 'dart:io';

import 'package:dicoding_story/presentation/main/add_story_modal.dart';
import 'package:dicoding_story/presentation/main/provider/main_provider.dart';
import 'package:dicoding_story/presentation/main/story_card.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> _showAddStoryDialog() async => showDialog(
    context: context,
    builder: (context) {
      final widthClass = WindowWidthClass.of(context);
      final heightClass = WindowHeightClass.of(context);
      if (!kIsWeb &&
          (Platform.isAndroid || Platform.isIOS) &&
          (widthClass < WindowWidthClass.medium ||
              heightClass < WindowHeightClass.medium)) {
        return Dialog.fullscreen(child: const AddStoryPage());
      }

      return AlertDialog(
        title: const Text('Tambah Cerita'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Cerita',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Gambar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Ceritakan pengalamanmu...',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Bagikan'),
          ),
        ],
      );
    },
  );

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
              actions: [
                IconButtonM3E(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widthClass >= WindowWidthClass.medium
                    ? GridView.builder(
                        key: const ValueKey('grid'),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisExtent: 400,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: stories.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return StoryCard(
                            story: story,
                            onTap: () => context.go('/story/${story.id}'),
                          );
                        },
                      )
                    : ListView.builder(
                        key: const ValueKey('list'),
                        padding: EdgeInsets.zero,
                        itemCount: stories.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final story = stories[index];
                          return StoryCard(
                            story: story,
                            onTap: () => context.go('/story/${story.id}'),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: isMedium ? _buildFABExtended() : _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      key: const ValueKey('fab_compact'),
      heroTag: 'fab_compact',
      onPressed: () => _showAddStoryDialog(),
      tooltip: 'Add Story',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildFABExtended() {
    return FloatingActionButton.extended(
      key: const ValueKey('fab_extended'),
      heroTag: 'fab_extended',
      onPressed: () => _showAddStoryDialog(),
      label: const Text('Add Story'),
      icon: const Icon(Icons.add),
      tooltip: 'Add Story',
    );
  }
}
