import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddStoryButton extends ConsumerWidget {
  const AddStoryButton({super.key, required this.descriptionController});

  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(addStoryProvider) is AddStoryLoading;
    final theme = Theme.of(context);
    final imageFile = ref.watch(imageFileProvider);
    final addStoryState = ref.watch(addStoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return FilledButton(
      onPressed: isLoading
          ? null
          : () async {
              final description = descriptionController.text.trim();
              if (description.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.addStoryErrorEmptyDescription),
                  ),
                );
                return;
              }
              if (imageFile == null) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(context.l10n.addStoryErrorEmptyImage)),
                );
                return;
              }

              final file = await ref.read(imageFileProvider.notifier).toFile();

              if (file != null) {
                // Call addStory
                await ref
                    .read(addStoryProvider.notifier)
                    .addStory(description: description, photo: file);
              }
            },
      child: addStoryState is AddStoryLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Text(context.l10n.addStoryBtnPost),
    );
  }
}
