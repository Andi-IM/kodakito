import 'dart:typed_data' show Uint8List;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_button.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_image_container.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/story_crop_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStoryDialog extends ConsumerStatefulWidget {
  final Future<Uint8List?> Function() getImageFile;
  const AddStoryDialog({super.key, required this.getImageFile});

  @override
  ConsumerState<AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends ConsumerState<AddStoryDialog> {
  final cropController = CropController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

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
    final imageFile = ref.watch(imageFileProvider.select((value) => value));
    final addStoryState = ref.watch(addStoryProvider);
    final isLoading = addStoryState is AddStoryLoading;

    ref.listen(addStoryProvider.select((value) => value), (prev, next) {
      if (next is AddStorySuccess) {
        ref.read(storiesProvider.notifier).fetchStories();
        // Clear the description
        descriptionController.clear();
        // Capture messenger reference before context is popped
        final messenger = ScaffoldMessenger.of(context);
        final localContext = context;
        // Show success message
        messenger.showSnackBar(
          SnackBar(content: Text(localContext.l10n.addStorySuccessMessage)),
        );
        // Close the dialog
        if (localContext.mounted) {
          Navigator.of(localContext).pop();
        }
      }
      if (next is AddStoryFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.exception.message)));
      }
    });

    return AlertDialog(
      title: Text(context.l10n.addStoryTitle),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400, maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.addStoryImageLabel,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AddStoryImageContainer(
                key: const ValueKey('addStoryImageContainer'),
                imageFile: imageFile,
                onTap: () => pickImage(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                enabled: !isLoading,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: context.l10n.addStoryDescriptionLabel,
                  hintText: context.l10n.addStoryDescriptionHint,
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
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.addStoryBtnCancel),
        ),
        //
        AddStoryButton(
          key: const ValueKey('addStoryButton'),
          isLoading: isLoading,
          descriptionController: descriptionController,
        ),
      ],
    );
  }
}
