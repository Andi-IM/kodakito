import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/data/services/location/location_service.dart';
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

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  late LatLng _selectedLocation;
  PlaceInfo? _placeInfo;
  GoogleMapController? _mapController;

  // Default location (Jakarta, Indonesia)
  static const LatLng _defaultLocation = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    // Convert PlaceInfo to LatLng if provided
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _placeInfo = widget.initialLocation;
    } else {
      _selectedLocation = _defaultLocation;
      // Auto-detect GPS location if no initial location provided
      _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final location = await ref
          .read(locationServiceProvider)
          .retrieveCurrentLocation();
      _placeInfo = location;
      final newLatLng = LatLng(location.latitude, location.longitude);
      if (mounted) {
        setState(() {
          _selectedLocation = newLatLng;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
      }
    } catch (_) {
      // Location permission denied or error - keep default/initial location
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.locationPickerTitle),
        actions: [
          TextButton(
            onPressed: () => context.pop(_placeInfo),
            child: Text(context.l10n.locationPickerConfirm),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation,
                draggable: true,
                onDragEnd: (newPosition) {
                  setState(() {
                    _selectedLocation = newPosition;
                  });
                },
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
                    final location = await ref
                        .read(locationServiceProvider)
                        .retrieveCurrentLocation();
                    final newLatLng = LatLng(
                      location.latitude,
                      location.longitude,
                    );
                    setState(() {
                      _selectedLocation = newLatLng;
                    });
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(newLatLng),
                    );
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom-in',
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom-out',
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
                child: Text(
                  _placeInfo != null
                      ? '${_placeInfo!.city}, ${_placeInfo!.state}'
                      : '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
