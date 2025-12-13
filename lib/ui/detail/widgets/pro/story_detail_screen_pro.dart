import 'dart:typed_data';

import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/map/map_controller_service.dart';
import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_detail_pro_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:m3e_collection/m3e_collection.dart';

class StoryDetailScreenPro extends ConsumerStatefulWidget {
  final String id;
  final Function onBack;

  /// Optional map widget to use instead of GoogleMap.
  /// Useful for widget tests where platform views are not supported.
  final Widget? mapOverride;

  /// Optional map controller service for dependency injection.
  /// If not provided, a default [MapControllerServiceImpl] is created.
  final MapControllerService? mapControllerService;

  const StoryDetailScreenPro({
    super.key,
    required this.id,
    required this.onBack,
    this.mapOverride,
    this.mapControllerService,
  });

  @override
  ConsumerState<StoryDetailScreenPro> createState() =>
      _StoryDetailPageProState();
}

class _StoryDetailPageProState extends ConsumerState<StoryDetailScreenPro>
    with LogMixin {
  late final MapControllerService _mapService;
  Set<Marker> _markers = {};
  bool _markersInitialized = false;

  // Controller for bottom sheet to track position
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    log.info('StoryDetailScreenPro initialized for story: ${widget.id}');
    _mapService = widget.mapControllerService ?? MapControllerServiceImpl();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    log.info('StoryDetailScreenPro disposed');
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    if (widget.mapControllerService == null) {
      _mapService.dispose();
    }
    super.dispose();
  }

  void _onSheetChanged() {
    if (_sheetController.isAttached) {
      ref.read(sheetExtentProvider.notifier).update(_sheetController.size);
    }
  }

  void _initializeMarkers(Story story, PlaceInfo? location) {
    if (_markersInitialized) return;

    if (story.lat != null && story.lon != null) {
      log.info('Initializing markers for story: ${story.id}');
      final storyPosition = LatLng(story.lat!, story.lon!);
      _markers = {
        Marker(
          markerId: MarkerId(story.id),
          position: storyPosition,
          infoWindow: InfoWindow(
            title: location != null
                ? '${location.city}, ${location.state}'
                : story.name,
            snippet: location != null ? story.name : null,
          ),
          onTap: () {
            log.info('Marker tapped, zooming to position');
            _mapService.animateToPosition(storyPosition, zoom: 18);
          },
        ),
      };
      _markersInitialized = true;
    }
  }

  Widget _buildGoogleMap(Story story) {
    final storyPosition = LatLng(story.lat!, story.lon!);

    // Use mapOverride if provided (for widget tests)
    if (widget.mapOverride != null) {
      return widget.mapOverride!;
    }

    return GoogleMap(
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: _markers,
      initialCameraPosition: CameraPosition(target: storyPosition, zoom: 15),
      onMapCreated: (GoogleMapController controller) {
        _mapService.setController(controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(detailScreenContentProvider(widget.id));
    final sheetExtent = ref.watch(sheetExtentProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Google Map - only show when loaded with correct initial position
          if (storyState is Loaded &&
              storyState.story.lat != null &&
              storyState.story.lon != null)
            Builder(
              builder: (context) {
                _initializeMarkers(storyState.story, storyState.location);
                return _buildGoogleMap(storyState.story);
              },
            )
          else if (storyState is Loaded)
            // Story loaded but no coordinates - show placeholder
            Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No location data',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            // Loading/Initial state - show placeholder background
            Container(color: colorScheme.surfaceContainerHighest),

          // Back button (top left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: "back",
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              onPressed: (storyState is Initial || storyState is Loading)
                  ? null
                  : () => widget.onBack(),
              child: const Icon(Icons.arrow_back),
            ),
          ),

          // Zoom controls (follows bottom sheet position) - only show when loaded
          if (storyState is Loaded)
            Positioned(
              bottom: screenHeight * sheetExtent + 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: "zoom-in",
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    onPressed: () => _mapService.zoomIn(),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: "zoom-out",
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    onPressed: () => _mapService.zoomOut(),
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),

          // Overlay loading indicator
          if (storyState is Initial || storyState is Loading)
            Container(
              color: Colors.black.withValues(alpha: .3),
              child: const Center(
                child: LoadingIndicatorM3E(
                  variant: LoadingIndicatorM3EVariant.contained,
                ),
              ),
            ),

          // Error state overlay
          if (storyState is Error)
            Container(
              color: Colors.black.withValues(alpha: .3),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          storyState.errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref
                              .read(
                                detailScreenContentProvider(widget.id).notifier,
                              )
                              .fetchDetailStory(widget.id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Draggable Bottom Sheet - only show when loaded
          if (storyState is Loaded)
            _StoryBottomSheet(
              story: storyState.story,
              location: storyState.location,
              imageBytes: storyState.imageBytes,
              colorScheme: colorScheme,
              controller: _sheetController,
            ),
        ],
      ),
    );
  }
}

class _StoryBottomSheet extends StatelessWidget {
  final Story story;
  final PlaceInfo? location;
  final Uint8List? imageBytes;
  final ColorScheme colorScheme;
  final DraggableScrollableController controller;

  const _StoryBottomSheet({
    required this.story,
    required this.location,
    required this.imageBytes,
    required this.colorScheme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: .4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // User info row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.onPrimaryContainer,
                        child: Text(
                          story.name[0].toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.primaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            DateFormat.yMMMMEEEEd(
                              context.l10n.localeName,
                            ).format(story.createdAt),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: .7),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Story image (visible when expanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            story.photoUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    story.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: .8,
                      ),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
