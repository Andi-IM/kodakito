import 'dart:typed_data' show Uint8List;

import 'package:dicoding_story/common/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStoryImageContainer extends ConsumerWidget {
  const AddStoryImageContainer({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  final Uint8List? imageFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(),
      child: Semantics(
        label: context.l10n.addStoryImageLabel,
        button: true,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(16),
            image: imageFile != null
                ? DecorationImage(
                    image: MemoryImage(imageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 50,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.addStoryUploadPlaceholder,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}
