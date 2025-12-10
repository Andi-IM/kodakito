import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/widget/image_picker/image_picker_service.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_button.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_image_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddStoryDialog extends ConsumerStatefulWidget {
  const AddStoryDialog({super.key});

  @override
  ConsumerState<AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends ConsumerState<AddStoryDialog> {
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addStoryState = ref.watch(addStoryProvider);
    final isLoading = addStoryState is AddStoryLoading;

    ref.listen(addStoryProvider.select((value) => value), (prev, next) {
      if (next is AddStorySuccess) {
        ref.read(storiesProvider.notifier).getStories();
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
          localContext.pop();
        }
      }
      if (next is AddStoryFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.exception.message)));
      }
    });

    final pickImage = ref.read(imagePickerServiceProvider);

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
                getImageFile: pickImage.pickImage,
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
          onPressed: isLoading ? null : () => context.pop(),
          child: Text(context.l10n.addStoryBtnCancel),
        ),
        //
        AddStoryButton(
          key: const ValueKey('addStoryButton'),
          descriptionController: descriptionController,
        ),
      ],
    );
  }
}
