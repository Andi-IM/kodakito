import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/data/services/widget/image_picker/image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/insta_image_picker/insta_image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/wechat_camera_picker/wechat_camera_picker_service.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/logo_widget.dart';
import 'package:dicoding_story/ui/main/widgets/add_story/wide/add_story_dialog.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:dicoding_story/ui/main/widgets/settings_dialog.dart';
import 'package:dicoding_story/ui/main/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
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

  Future<void> _pickFromWeChatCamera(BuildContext context) async {
    Feedback.forTap(context);
    final AssetEntity? entity = await ref
        .read(cameraPickerServiceProvider)
        .pickImage(context);
    if (entity == null) return;

    if (context.mounted) {
      await ref
          .read(instaImagePickerServiceProvider)
          .refreshAndSelectEntity(context, entity);
    }
  }

  Future<void> showAddStoryDialog({required bool isMobilePlatform}) async {
    if (isMobilePlatform) {
      ref
          .read(instaImagePickerServiceProvider)
          .pickImage(
            context,
            _pickFromWeChatCamera,
            (cropStream) => context.pushNamed('add-story', extra: cropStream),
          );
      return;
    }

    return showDialog(
      context: context,
      builder: (context) => AddStoryDialog(
        getImageFile: () async =>
            await ref.read(imagePickerServiceProvider).pickImage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePlatform = ref.watch(mobilePlatformProvider);
    final widthClass = WindowWidthClass.of(context);
    final isMedium = widthClass >= WindowWidthClass.medium;
    final isLarge = widthClass >= WindowWidthClass.large;

    final storiesAsync = ref.watch(storiesProvider);
    final userAsync = ref.watch(fetchUserDataProvider);
    return Scaffold(
      body: storiesAsync.when(
        data: (stories) {
          final scrollView = CustomScrollView(
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
                    key: const ValueKey('avatarButton'),
                    onPressed: () => showDialog(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => SettingsDialog(),
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
          );

          final scrollbarChild = Scrollbar(
            controller: _scrollController,
            child: scrollView,
          );

          // Wrap with RefreshIndicator for mobile platforms
          return isMobilePlatform
              ? RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(storiesProvider.notifier).fetchStories();
                  },
                  child: scrollbarChild,
                )
              : scrollbarChild;
        },
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
        child: _buildFAB(isMedium, isMobilePlatform: isMobilePlatform),
      ),
    );
  }

  Widget _buildFAB(bool isMediumWidth, {required bool isMobilePlatform}) {
    if (isMediumWidth) {
      return FloatingActionButton.extended(
        key: const ValueKey('fab_extended'),
        heroTag: 'fab_extended',
        onPressed: () => showAddStoryDialog(isMobilePlatform: isMobilePlatform),
        label: Text(context.l10n.addStoryTitle),
        icon: const Icon(Icons.add),
        tooltip: context.l10n.addStoryTitle,
      );
    }
    return FloatingActionButton(
      key: const ValueKey('fab_compact'),
      heroTag: 'fab_compact',
      onPressed: () => showAddStoryDialog(isMobilePlatform: isMobilePlatform),
      tooltip: context.l10n.addStoryTitle,
      child: const Icon(Icons.add),
    );
  }
}
