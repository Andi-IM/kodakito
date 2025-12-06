import 'dart:io';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ref.listen(getCroppedImageFromPickerProvider(widget.cropStream), (
      previous,
      next,
    ) {
      if (next.hasValue && next.value != null) {
        file = next.value;
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addStoryTitle),
        actions: [
          TextButton(
            onPressed: () {
              if (file != null) {
                ref
                    .read(addStoryProvider.notifier)
                    .addStory(
                      description: _descriptionController.text,
                      photo: file!,
                    );
              }
            },
            child: Text(context.l10n.addStoryBtnPost),
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
                final file = snapshot.data?.data.firstOrNull?.croppedFile;
                if (file != null) {
                  return SizedBox(
                    height: 400,
                    width: 400,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, fit: BoxFit.cover),
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
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: context.l10n.addStoryDescriptionHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
