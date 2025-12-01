import 'package:dicoding_story/common/localizations.dart';
import 'package:flutter/material.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

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
        actions: [TextButton(onPressed: () {}, child: Text(context.l10n.addStoryBtnPost))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                  label: Text(context.l10n.addStoryBtnCamera),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo),
                  label: Text(context.l10n.addStoryBtnGallery),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: context.l10n.addStoryDescriptionHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: Text(context.l10n.addStoryBtnCancel)),
          ],
        ),
      ),
    );
  }
}
