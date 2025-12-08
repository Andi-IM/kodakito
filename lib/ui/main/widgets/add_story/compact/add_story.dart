import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';

class AddStoryPage extends ConsumerStatefulWidget {
  const AddStoryPage({
    super.key,
    required this.cropStream,
    this.onAddStorySuccess,
  });

  final Function()? onAddStorySuccess;
  final Stream<InstaAssetsExportDetails> cropStream;

  @override
  ConsumerState<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends ConsumerState<AddStoryPage> {
  final TextEditingController _descriptionController = TextEditingController();
  XFile? file;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to add story state changes
    ref.listen(addStoryProvider, (previous, next) {
      if (next is AddStorySuccess) {
        widget.onAddStorySuccess?.call();
      }
      if (next is AddStoryFailure) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.exception.message),
              backgroundColor: Colors.red,
            ),
          );
          // Reset state so user can try again
          ref.read(addStoryProvider.notifier).resetState();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addStoryTitle),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final addStoryState = ref.watch(addStoryProvider);
              return TextButton(
                key: const Key('postButton'),
                onPressed: addStoryState is AddStoryLoading
                    ? null
                    : () async {
                        if (file == null) return;
                        ref
                            .read(addStoryProvider.notifier)
                            .addStory(
                              description: _descriptionController.text,
                              photoFile: file!,
                            );
                      },
                child: addStoryState is AddStoryLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.addStoryBtnPost),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<InstaAssetsExportDetails>(
              stream: widget.cropStream,
              builder: (context, snapshot) {
                final croppedFile =
                    snapshot.data?.data.firstOrNull?.croppedFile;
                if (croppedFile != null) {
                  // Update file reference for posting
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && file?.path != croppedFile.path) {
                      setState(() {
                        file = XFile(croppedFile.path);
                      });
                    }
                  });

                  return SizedBox(
                    height: 400,
                    width: 400,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(croppedFile, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.addStoryDescriptionLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Consumer(
              builder: (context, ref, child) {
                final addStoryState = ref.watch(addStoryProvider);
                final isLoading = addStoryState is AddStoryLoading;

                return TextField(
                  key: const Key('descriptionField'),
                  controller: _descriptionController,
                  maxLines: 5,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: context.l10n.addStoryDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
