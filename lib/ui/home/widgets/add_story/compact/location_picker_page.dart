import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/home/view_model/location_picker_view_model.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong_to_place/latlong_to_place.dart';

/// A page that allows the user to pick a location on a map.
class LocationPickerPage extends ConsumerStatefulWidget {
  final PlaceInfo? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage>
    with LogMixin {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    log.info('LocationPickerPage initialized');
  }

  @override
  void dispose() {
    log.info('LocationPickerPage disposed');
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(
      locationPickerProvider(widget.initialLocation),
    );

    ref.listen(locationPickerProvider(widget.initialLocation), (prev, next) {
      if (prev?.selectedLocation != next.selectedLocation) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(next.selectedLocation),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.locationPickerTitle),
        actions: [
          TextButton(
            onPressed: () => context.pop(locationState.placeInfo),
            child: Text(context.l10n.locationPickerConfirm),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationState.selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (latLng) => ref
                .read(locationPickerProvider(widget.initialLocation).notifier)
                .updateLocation(latLng),
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: locationState.selectedLocation,
                draggable: true,
                onDragEnd: (newPosition) => ref
                    .read(
                      locationPickerProvider(widget.initialLocation).notifier,
                    )
                    .updateLocation(newPosition),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          // Instructions overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  context.l10n.locationPickerHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          // Zoom controls
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                // My location button
                FloatingActionButton.small(
                  heroTag: 'my-location',
                  onPressed: () async {
                    final newLatLng = await ref
                        .read(
                          locationPickerProvider(
                            widget.initialLocation,
                          ).notifier,
                        )
                        .moveToCurrentLocation();
                    if (newLatLng != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(newLatLng),
                      );
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'location-picker-zoom-in',
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'location-picker-zoom-out',
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          // Coordinates display
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: locationState.isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Text(
                        locationState.placeInfo != null
                            ? '${locationState.placeInfo!.city}, ${locationState.placeInfo!.state}'
                            : '${locationState.selectedLocation.latitude.toStringAsFixed(6)}, ${locationState.selectedLocation.longitude.toStringAsFixed(6)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
