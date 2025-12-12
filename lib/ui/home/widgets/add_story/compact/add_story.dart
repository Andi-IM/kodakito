import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/common/routing/app_router/go_router_builder.dart';
import 'package:dicoding_story/ui/home/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/home/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:latlong_to_place/latlong_to_place.dart';

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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final currentLocation = ref.read(selectedLocationProvider);
    final result = await context.pushNamed<PlaceInfo>(
      Routing.pickLocation,
      extra: currentLocation,
    );
    if (result != null) {
      ref.read(selectedLocationProvider.notifier).setLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(selectedLocationProvider);

    // Listen to add story state changes
    ref.listen(addStoryProvider, (previous, next) {
      if (next is AddStorySuccess) {
        // Clear state when story is posted successfully
        ref.read(selectedLocationProvider.notifier).clear();
        ref.read(selectedPhotoFileProvider.notifier).clear();
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
              final location = ref.watch(selectedLocationProvider);
              final photoFile = ref.watch(selectedPhotoFileProvider);
              return TextButton(
                key: const Key('postButton'),
                onPressed: addStoryState is AddStoryLoading || photoFile == null
                    ? null
                    : () async {
                        ref
                            .read(addStoryProvider.notifier)
                            .addStory(
                              description: _descriptionController.text,
                              photoFile: photoFile,
                              lat: location?.latitude,
                              lon: location?.longitude,
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
                  // Update file reference in view model
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final currentFile = ref.read(selectedPhotoFileProvider);
                    if (mounted && currentFile?.path != croppedFile.path) {
                      ref
                          .read(selectedPhotoFileProvider.notifier)
                          .setFile(XFile(croppedFile.path));
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
            const SizedBox(height: 16),
            // Location picker button
            Consumer(
              builder: (context, ref, child) {
                final addStoryState = ref.watch(addStoryProvider);
                final isLoading = addStoryState is AddStoryLoading;
                final location = ref.watch(selectedLocationProvider);

                return OutlinedButton.icon(
                  key: const Key('locationButton'),
                  onPressed: isLoading ? null : _openLocationPicker,
                  icon: Icon(
                    location != null
                        ? Icons.location_on
                        : Icons.add_location_alt,
                  ),
                  label: Text(
                    location != null
                        ? '${location.city}, ${location.country}'
                        : context.l10n.addStoryAddLocation,
                  ),
                );
              },
            ),
            if (selectedLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    ref.read(selectedLocationProvider.notifier).clear();
                  },
                  child: Text(
                    context.l10n.addStoryRemoveLocation,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
