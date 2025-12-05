import 'package:cached_network_image/cached_network_image.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart' hide Config;

class StoryDetailCompactLayout extends StatelessWidget {
  final Story story;
  const StoryDetailCompactLayout({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: story.id,
              child: Semantics(
                key: ValueKey('image_${story.id}'),
                label: 'Image of ${story.name}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: story.photoUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheKey: 'storyDetailKey_${story.id}',
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Semantics(
                        key: ValueKey('avatar_${story.id}'),
                        label: 'Avatar of ${story.name}',
                        child: CircleAvatar(
                          backgroundColor: colorScheme.surface,
                          child: Text(
                            story.name[0].toUpperCase(),
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key: ValueKey('name_${story.id}'),
                            story.name,
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            key: ValueKey('date_${story.id}'),
                            story.createdAt.toString().split(' ')[0],
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    key: ValueKey('description_${story.id}'),
                    story.description,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
