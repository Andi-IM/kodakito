import 'dart:typed_data';

import 'package:dicoding_story/domain/models/story/story.dart';
import 'package:dicoding_story/ui/detail/view_models/detail_view_model.dart';
import 'package:dicoding_story/ui/detail/view_models/story_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoryDetailPagePro extends ConsumerStatefulWidget {
  final String id;
  const StoryDetailPagePro({super.key, required this.id});

  @override
  ConsumerState<StoryDetailPagePro> createState() => _StoryDetailPageProState();
}

class _StoryDetailPageProState extends ConsumerState<StoryDetailPagePro> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _markersInitialized = false;

  // Controller for bottom sheet to track position
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetExtent = 0.25; // Initial extent

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    if (_sheetController.isAttached) {
      setState(() {
        _sheetExtent = _sheetController.size;
      });
    }
  }

  void _initializeMarkers(Story story) {
    if (_markersInitialized) return;

    if (story.lat != null && story.lon != null) {
      final storyPosition = LatLng(story.lat!, story.lon!);
      _markers = {
        Marker(
          markerId: MarkerId(story.id),
          position: storyPosition,
          infoWindow: InfoWindow(title: story.name),
          onTap: () {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(storyPosition, 18),
            );
          },
        ),
      };
      _markersInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(detailScreenContentProvider(widget.id));
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
                _initializeMarkers(storyState.story);
                final storyPosition = LatLng(
                  storyState.story.lat!,
                  storyState.story.lon!,
                );
                return GoogleMap(
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: storyPosition,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                );
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back),
            ),
          ),

          // Zoom controls (follows bottom sheet position)
          Positioned(
            bottom: screenHeight * _sheetExtent + 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom-in",
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  onPressed: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom-out",
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  onPressed: () =>
                      _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // Overlay loading indicator
          if (storyState is Initial || storyState is Loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Error state overlay
          if (storyState is Error)
            Container(
              color: Colors.black.withOpacity(0.3),
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
  final Uint8List? imageBytes;
  final ColorScheme colorScheme;
  final DraggableScrollableController controller;

  const _StoryBottomSheet({
    required this.story,
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
                color: Colors.black.withOpacity(0.1),
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
                      color: colorScheme.onPrimaryContainer.withOpacity(0.4),
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
                            _formatDate(story.createdAt),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Location chip (if location available)
                if (story.lat != null && story.lon != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${story.lat!.toStringAsFixed(4)}, ${story.lon!.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
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

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final dayName = days[date.weekday - 1];
    return '$dayName, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
