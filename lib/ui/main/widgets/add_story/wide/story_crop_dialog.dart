import 'dart:typed_data' show Uint8List;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StoryCropDialog extends ConsumerWidget {
  const StoryCropDialog({
    super.key,
    required this.imageBytes,
    required this.cropController,
  });

  final Uint8List imageBytes;
  final CropController cropController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: SizedBox(
        width: 500,
        height: 500,
        child: Crop(
          image: imageBytes,
          controller: cropController,
          onCropped: (result) {
            if (result is CropSuccess) {
              ref
                  .read(imageFileProvider.notifier)
                  .setImageFile(result.croppedImage);
            }
            context.pop();
          },
          aspectRatio: 1,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(context.l10n.addStoryBtnCancel),
        ),
        FilledButton(
          onPressed: () => cropController.crop(),
          child: Text(context.l10n.addStoryBtnCameraCrop),
        ),
      ],
    );
  }
}
