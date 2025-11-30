import 'package:dicoding_story/data/model/story.dart';
import 'package:dicoding_story/presentation/detail/provider/detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:window_size_classes/window_size_classes.dart';

class StoryDetailPage extends ConsumerStatefulWidget {
  final int id;

  const StoryDetailPage({super.key, required this.id});

  @override
  ConsumerState<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends ConsumerState<StoryDetailPage> {
  Story? _story;
  ColorScheme? _colorScheme;

  @override
  void initState() {
    super.initState();
    _story = ref.read(detailScreenContentProvider);
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      NetworkImage(_story!.photoUrl),
      size: const Size(200, 100),
    );

    if (mounted) {
      setState(() {
        if (generator.dominantColor != null) {
          _colorScheme = ColorScheme.fromSeed(
            seedColor: generator.dominantColor!.color,
            brightness: Theme.of(context).brightness,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = _colorScheme ?? theme.colorScheme;

    return Theme(
      data: theme.copyWith(colorScheme: colorScheme),
      child: Scaffold(
        backgroundColor: _colorScheme?.surface,
        appBar: AppBar(
          title: const Text('Story Detail'),
          backgroundColor: _colorScheme?.surface,
          foregroundColor: _colorScheme?.onSurface,
        ),
        body: SingleChildScrollView(
          child: Builder(
            builder: (context) {
              final widthClass = WindowWidthClass.of(context);
              if (widthClass >= WindowWidthClass.medium) {
                return buildMediumExtendContent(colorScheme);
              }
              return buildCompactContent(colorScheme);
            },
          ),
        ),
      ),
    );
  }

  Widget buildCompactContent(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Text(
                    _story!.name[0].toUpperCase(),
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _story!.name,
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _story!.createdAt.toString().split(' ')[0],
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Hero(
            tag: _story!.id,
            child: Image.network(
              _story!.photoUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _story!.description,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMediumExtendContent(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: AspectRatio(
            aspectRatio: 1,
            child: Hero(
              tag: _story!.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _story!.photoUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Text(
                        _story!.name[0].toUpperCase(),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _story!.name,
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.normal,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _story!.createdAt.toString().split(' ')[0],
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _story!.description,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
