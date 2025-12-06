import 'dart:io';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/l10n/app_asset_picker_text_delegate.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/logo_widget.dart';
import 'package:dicoding_story/ui/main/widgets/add_story_dialog.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/settings_dialog.dart';
import 'package:dicoding_story/ui/main/widgets/story_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:window_size_classes/window_size_classes.dart';
import 'package:m3e_collection/m3e_collection.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storiesProvider.notifier).fetchStories();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ResolutionPreset get cameraResolutionPreset =>
      Platform.isAndroid ? ResolutionPreset.high : ResolutionPreset.max;

  Future<void> _pickFromWeChatCamera(BuildContext context) async {
    Feedback.forTap(context);
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      context,
      locale: Localizations.maybeLocaleOf(context),
      pickerConfig: CameraPickerConfig(
        theme: Theme.of(context),
        resolutionPreset: cameraResolutionPreset,
        enableRecording: false,
      ),
    );
    if (entity == null) return;

    if (context.mounted) {
      await InstaAssetPicker.refreshAndSelectEntity(context, entity);
    }
  }

  Future<void> showAddStoryDialog() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      InstaAssetPicker.pickAssets(
        context,
        pickerConfig: InstaAssetPickerConfig(
          title: context.l10n.addStoryTitle,
          closeOnComplete: true,
          textDelegate: context.l10n.localeName == 'id' ? IndonesianAssetPickerTextDelegate() : null,
          pickerTheme:
              InstaAssetPicker.themeData(
                Theme.of(context).colorScheme.primary,
              ).copyWith(
                appBarTheme: AppBarTheme(
                  titleTextStyle: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
          actionsBuilder: (context, theme, height, unselectAll) => [
            InstaPickerCircleIconButton.unselectAll(
              onTap: unselectAll,
              theme: theme,
              size: height,
            ),
          ],
          specialItemBuilder: (context, _, __) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: IconButton(
                onPressed: () => _pickFromWeChatCamera(context),
                icon: const Icon(Icons.camera_alt),
              ),
            );
          },
          specialItemPosition: SpecialItemPosition.prepend,
        ),
        maxAssets: 1,
        onCompleted: (cropStream) {
          return context.pushNamed('add-story', extra: cropStream);
        },
      );
      return;
    }

    return showDialog(context: context, builder: (context) => AddStoryDialog());
  }

  @override
  Widget build(BuildContext context) {
    final widthClass = WindowWidthClass.of(context);
    final isMedium = widthClass >= WindowWidthClass.medium;
    final isLarge = widthClass >= WindowWidthClass.large;

    final storiesAsync = ref.watch(storiesProvider);
    final userAsync = ref.watch(fetchUserDataProvider);
    return Scaffold(
      body: storiesAsync.when(
        data: (stories) => Scrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                title: Padding(
                  padding: const EdgeInsets.only(left: 48.0),
                  child: LogoWidget(maxWidth: 200),
                ),
                centerTitle: true,
                pinned: false,
                actions: [
                  IconButtonM3E(
                    key: const ValueKey('debugCoordinatesButton'),
                    onPressed: () => context.pushNamed('debug-coordinates'),
                    icon: const Icon(Icons.dangerous),
                  ),
                  IconButtonM3E(
                    key: const ValueKey('avatarButton'),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return SettingsDialog();
                      },
                    ),
                    icon: userAsync.when(
                      data: (name) => CircleAvatar(
                        radius: 16,
                        child: Text(
                          (name != null && name.isNotEmpty)
                              ? name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      error: (_, __) => const Icon(Icons.account_circle),
                      loading: () => const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    tooltip: context.l10n.settingsTitle,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isMedium
                      ? GridView.builder(
                          key: const ValueKey('grid'),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                mainAxisExtent: 400,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: stories.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final story = stories[index];
                            return StoryCard(
                              story: story,
                              onTap: () => context.go('/story/${story.id}'),
                            );
                          },
                        )
                      : ListView.builder(
                          key: const ValueKey('list'),
                          padding: EdgeInsets.zero,
                          itemCount: stories.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final story = stories[index];
                            return StoryCard(
                              key: ValueKey('StoryCard_${story.id}'),
                              story: story,
                              onTap: () => context.go('/story/${story.id}'),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
        loading: () => Center(
          child: isMedium
              ? SizedBox(
                  width: isLarge ? 240 : 120,
                  height: isLarge ? 240 : 120,
                  child: LoadingIndicatorM3E(
                    key: const ValueKey('loadingIndicator'),
                    semanticLabel: 'loading_stories',
                  ),
                )
              : LoadingIndicatorM3E(
                  key: const ValueKey('loadingIndicator'),
                  semanticLabel: 'loading_stories',
                ),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: isMedium ? _buildFABExtended() : _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      key: const ValueKey('fab_compact'),
      heroTag: 'fab_compact',
      onPressed: () => showAddStoryDialog(),
      tooltip: context.l10n.addStoryTitle,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildFABExtended() {
    return FloatingActionButton.extended(
      key: const ValueKey('fab_extended'),
      heroTag: 'fab_extended',
      onPressed: () => showAddStoryDialog(),
      label: Text(context.l10n.addStoryTitle),
      icon: const Icon(Icons.add),
      tooltip: context.l10n.addStoryTitle,
    );
  }
}
