import 'dart:typed_data' show Uint8List;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/story_crop_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStoryImageContainer extends ConsumerStatefulWidget {
  const AddStoryImageContainer({super.key, required this.getImageFile});

  final Future<Uint8List?> Function() getImageFile;

  @override
  ConsumerState<AddStoryImageContainer> createState() =>
      _AddStoryImageContainerState();
}

class _AddStoryImageContainerState
    extends ConsumerState<AddStoryImageContainer> {
  final cropController = CropController();
  void pickImage() async {
    final imageBytes = await widget.getImageFile();
    if (imageBytes != null) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => StoryCropDialog(
            imageBytes: imageBytes,
            cropController: cropController,
            ref: ref,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageFile = ref.watch(imageFileProvider.select((value) => value));
    return GestureDetector(
      onTap: () => pickImage(),
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
                    image: MemoryImage(imageFile),
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
