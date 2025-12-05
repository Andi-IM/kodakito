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

    // Watch the color scheme provider based on the story's photo URL
    final colorSchemeAsync = storyState is Loaded
        ? ref.watch(storyColorSchemeProvider(storyState.story.photoUrl))
        : const AsyncValue<ColorScheme?>.data(null);

    // Get the color scheme, falling back to theme default
    final colorScheme = colorSchemeAsync.when(
      data: (scheme) =>
          scheme?.copyWith(brightness: theme.brightness) ?? theme.colorScheme,
      loading: () => theme.colorScheme,
      error: (_, __) => theme.colorScheme,
    );

    return Theme(
      data: theme.copyWith(colorScheme: colorScheme),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            context.l10n.storyDetailTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: StoryDetailContent(
          key: const ValueKey('StoryDetailContent'),
          storyState: storyState,
        ),
      ),
    );
  }
}

class StoryDetailContent extends StatelessWidget {
  const StoryDetailContent({super.key, required this.storyState});

  final StoryState storyState;

  @override
  Widget build(BuildContext context) {
    return switch (storyState) {
      Loading() => const Center(child: CircularProgressIndicator()),
      Error(errorMessage: final message) => Center(child: Text(message)),
      Loaded(story: final story) => _StoryDetailLoadedContent(story: story),
      _ => const Center(
        child: Text('No Data'),
      ), // Handles null story or other unexpected states
    };
  }
}

class _StoryDetailLoadedContent extends StatelessWidget {
  const _StoryDetailLoadedContent({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }
}
