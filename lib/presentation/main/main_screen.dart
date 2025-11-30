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
                IconButton(
                  onPressed: () => context.pushNamed('bookmark'),
                  icon: const Icon(Icons.bookmark_outline),
                  tooltip: 'Bookmark',
                ),
                IconButton(
                  onPressed: () => context.pushNamed('profile'),
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Profile',
                ),
              ],
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton({double? elevation}) {
    return FloatingActionButton(
      elevation: elevation,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
              return Dialog.fullscreen(child: const AddStoryPage());
            }

            return AlertDialog(
              title: const Text('Tambah Cerita'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 400,
                    maxWidth: 800,
                  ),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload Gambar',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
      },
      tooltip: 'Add Story',
      child: const Icon(Icons.add),
    );
  }
}
