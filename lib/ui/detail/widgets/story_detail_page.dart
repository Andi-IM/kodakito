import 'dart:typed_data' show Uint8List;

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_compact_layout.dart';
import 'package:dicoding_story/ui/detail/widgets/story_detail_medium_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_size_classes/window_size_classes.dart';

class StoryDetailPage extends ConsumerWidget {
  final String id;

  const StoryDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyState = ref.watch(detailScreenContentProvider(id));
    final theme = Theme.of(context);

    return switch (storyState) {
      Error(errorMessage: final message) => Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.storyDetailTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: Center(child: Text(message)),
      ),
      Loaded(story: final story, imageBytes: final imageBytes) =>
        _StoryDetailContent(story: story, imageBytes: imageBytes),
      _ => Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.storyDetailTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      ), // Handles null story or other unexpected states
    };
  }
}

class _StoryDetailContent extends ConsumerWidget {
  const _StoryDetailContent({required this.story, required this.imageBytes});

  final Story story;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(storyColorSchemeProvider(imageBytes));
    final theme = Theme.of(context);

    return colorScheme.when(
      loading: () =>
          Scaffold(
            appBar: AppBar(
              title: Text(
                context.l10n.storyDetailTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
      data: (colorScheme) => Theme(
        data: theme.copyWith(colorScheme: colorScheme),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              context.l10n.storyDetailTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Builder(
              builder: (context) {
                final widthClass = WindowWidthClass.of(context);
                if (widthClass >= WindowWidthClass.medium) {
                  return StoryDetailMediumLayout(
                    key: const ValueKey("MediumLayout"),
                    story: story,
                  );
                }
                return StoryDetailCompactLayout(
                  key: const ValueKey("CompactLayout"),
                  story: story,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
