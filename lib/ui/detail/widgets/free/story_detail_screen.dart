import 'dart:typed_data' show Uint8List;

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/ui/detail/widgets/free/story_detail_compact_layout.dart';
import 'package:dicoding_story/ui/detail/widgets/free/story_detail_medium_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:window_size_classes/window_size_classes.dart';

class StoryDetailScreen extends ConsumerWidget {
  static final _log = Logger('StoryDetailScreen');
  final String id;

  const StoryDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _log.info('Building StoryDetailScreen for story: $id');
    final storyState = ref.watch(detailScreenContentProvider(id));
    final theme = Theme.of(context);

    return switch (storyState) {
      Error(errorMessage: final message) => (() {
        _log.warning('Story detail error: $message');
        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.l10n.storyDetailTitle,
              style: theme.textTheme.titleLarge,
            ),
            centerTitle: true,
          ),
          body: Center(child: Text(message)),
        );
      })(),
      Loaded(story: final story, imageBytes: final imageBytes) => (() {
        _log.info('Story detail loaded: ${story.name}');
        return _StoryDetailContent(story: story, imageBytes: imageBytes);
      })(),
      _ => (() {
        _log.info('Story detail loading...');
        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.l10n.storyDetailTitle,
              style: theme.textTheme.titleLarge,
            ),
            centerTitle: true,
          ),
          body: Center(
            child: const LoadingIndicatorM3E(
              variant: LoadingIndicatorM3EVariant.contained,
            ),
          ),
        );
      })(),
    };
  }
}

class _StoryDetailContent extends ConsumerWidget {
  const _StoryDetailContent({required this.story, required this.imageBytes});

  final Story story;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorSchemeAsync = ref.watch(storyColorSchemeProvider(imageBytes));
    final theme = Theme.of(context);
    // Use the fetched color scheme if available, otherwise fallback to the current theme's scheme.
    // This allows AnimatedTheme to interpolate from the default scheme to the extracted one.
    final targetColorScheme =
        colorSchemeAsync.asData?.value ?? theme.colorScheme;

    return AnimatedTheme(
      data: theme.copyWith(colorScheme: targetColorScheme),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.storyDetailTitle,
            style: theme.textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: colorSchemeAsync.isLoading
              ? const Center(
                  key: ValueKey('loading'),
                  child: LoadingIndicatorM3E(
                    variant: LoadingIndicatorM3EVariant.contained,
                  ),
                )
              : SingleChildScrollView(
                  key: const ValueKey('content'),
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
