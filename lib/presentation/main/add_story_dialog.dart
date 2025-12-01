import 'package:crop_your_image/crop_your_image.dart';
import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/presentation/main/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddStoryDialog extends ConsumerStatefulWidget {
  const AddStoryDialog({super.key});

  @override
  ConsumerState<AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends ConsumerState<AddStoryDialog> {
  final cropController = CropController();
  @override
  Widget build(BuildContext context) {
    final imageFile = ref.watch(imageFileProvider);
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
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    if (context.mounted) {
                      final imageBytes = await image.readAsBytes();
                      if (context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
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
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  cropController.crop();
                                },
                                child: const Text('Crop'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
                child: Semantics(
                  label: context.l10n.addStoryImageLabel,
                  button: true,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.addStoryUploadPlaceholder,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
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
          onPressed: () => context.pop(),
          child: Text(context.l10n.addStoryBtnCancel),
        ),
        FilledButton(
          onPressed: () => context.pop(),
          child: Text(context.l10n.addStoryBtnPost),
        ),
      ],
    );
  }
}
