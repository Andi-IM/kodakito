import 'dart:io';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';

class AddStoryPage extends ConsumerStatefulWidget {
  const AddStoryPage({super.key, required this.cropStream});

  final Stream<InstaAssetsExportDetails> cropStream;

  @override
  ConsumerState<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends ConsumerState<AddStoryPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? file;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to add story state changes
    ref.listen(addStoryProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: () {
          // Navigate back on success
          if (mounted) {
            // Reset the provider state for next time
            ref.read(addStoryProvider.notifier).resetState();
            
            context.pushReplacementNamed('main');
          }
        },
        failure: (failure) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
            // Reset state so user can try again
            ref.read(addStoryProvider.notifier).resetState();
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addStoryTitle),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final addStoryState = ref.watch(addStoryProvider);
              final isLoading = addStoryState.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return TextButton(
                key: const Key('postButton'),
                onPressed: isLoading
                    ? null
                    : () {
                        if (file != null) {
                          ref
                              .read(addStoryProvider.notifier)
                              .addStory(
                                description: _descriptionController.text,
                                photo: file!,
                              );
                        }
                      },
                child: isLoading
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
                    if (mounted && file != croppedFile) {
                      setState(() {
                        file = croppedFile;
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
                final isLoading = addStoryState.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );

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
