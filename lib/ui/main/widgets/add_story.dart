import 'package:dicoding_story/common/localizations.dart';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key, required this.cropStream});

  final Stream<InstaAssetsExportDetails> cropStream;

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.addStoryTitle),
        actions: [
          TextButton(
            onPressed: () {},
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
