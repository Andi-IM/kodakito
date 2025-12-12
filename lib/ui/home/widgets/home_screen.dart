import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/common/routing/app_router/go_router_builder.dart';
import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:dicoding_story/data/services/widget/insta_image_picker/insta_image_picker_service.dart';
import 'package:dicoding_story/data/services/widget/wechat_camera_picker/wechat_camera_picker_service.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/logo_widget.dart';
import 'package:dicoding_story/ui/home/view_model/home_view_model.dart';
import 'package:dicoding_story/ui/home/widgets/story_card.dart';
import 'package:dicoding_story/ui/home/widgets/story_card_skeleton.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:window_size_classes/window_size_classes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<HomeScreen> with LogMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    log.info('HomeScreen initialized');
    Future.microtask(() async {
      log.info('Fetching initial stories');
      await ref.read(storiesProvider.notifier).getStories();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      log.info('Reached bottom of list, loading more stories');
      ref.read(storiesProvider.notifier).getStories();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    log.info('HomeScreen disposed');
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
    log.info('showAddStoryDialog called, isMobile: $isMobilePlatform');
    if (isMobilePlatform) {
      log.info('Opening mobile image picker');
      ref.read(instaImagePickerServiceProvider).pickImage(
        context,
        _pickFromWeChatCamera,
        (cropStream) {
          log.info('Navigating to post story route');
          context.goNamed(
            Routing.post,
            extra: PostStoryRouteExtra(cropStream: cropStream),
          );
        },
      );
      return;
    }

    log.info('Opening desktop add story dialog');
    PostStoryRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePlatform = ref.watch(mobilePlatformProvider);
    final widthClass = WindowWidthClass.of(context);
    final isMedium = widthClass >= WindowWidthClass.medium;
    final isLarge = widthClass >= WindowWidthClass.large;

    final storiesState = ref.watch(storiesProvider);
    final userAsync = ref.watch(fetchUserDataProvider).value;

    // Build the body based on state
    Widget body;
    if (storiesState.isInitialLoading) {
      body = Center(
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
      );
    } else if (storiesState.hasError && storiesState.stories.isEmpty) {
      body = Center(child: Text('Error: ${storiesState.errorMessage}'));
    } else {
      final stories = storiesState.stories;
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
                onPressed: () => context.push('/settings'),
                icon: CircleAvatar(
                  radius: 16,
                  child: Text(
                    (userAsync != null && userAsync.isNotEmpty)
                        ? userAsync[0].toUpperCase()
                        : '?',
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
                          onTap: () => DetailRoute(id: story.id).go(context),
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
                          onTap: () => DetailRoute(
                            id: story.id,
                            hasLocation: story.lat != null && story.lon != null,
                          ).go(context),
                        );
                      },
                    ),
            ),
          ),
          // Show skeleton loading when fetching more stories
          if (storiesState.isLoadingMore)
            const SliverToBoxAdapter(child: StoryCardSkeleton()),
        ],
      );

      final scrollbarChild = Scrollbar(
        controller: _scrollController,
        child: scrollView,
      );

      // Wrap with RefreshIndicator for mobile platforms
      body = isMobilePlatform
          ? RefreshIndicator(
              onRefresh: () async {
                await ref.read(storiesProvider.notifier).getStories();
              },
              child: scrollbarChild,
            )
          : scrollbarChild;
    }

    return Scaffold(
      body: body,
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
