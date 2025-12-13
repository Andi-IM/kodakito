import 'package:dicoding_story/data/services/location/location_service.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_picker_view_model.g.dart';

/// State class for LocationPicker
class LocationPickerState {
  final LatLng selectedLocation;
  final PlaceInfo? placeInfo;
  final bool isLoading;

  const LocationPickerState({
    required this.selectedLocation,
    this.placeInfo,
    this.isLoading = false,
  });

  LocationPickerState copyWith({
    LatLng? selectedLocation,
    PlaceInfo? placeInfo,
    bool? isLoading,
    bool clearPlaceInfo = false,
  }) {
    return LocationPickerState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      placeInfo: clearPlaceInfo ? null : (placeInfo ?? this.placeInfo),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for managing LocationPicker state
@riverpod
class LocationPicker extends _$LocationPicker with LogMixin {
  // Default location (Jakarta, Indonesia)
  static const LatLng defaultLocation = LatLng(-6.2088, 106.8456);

  LocationService get _locationService => ref.read(locationServiceProvider);

  @override
  LocationPickerState build(PlaceInfo? initialLocation) {
    if (initialLocation != null) {
      log.info('LocationPicker initialized with: ${initialLocation.city}');
      return LocationPickerState(
        selectedLocation: LatLng(
          initialLocation.latitude,
          initialLocation.longitude,
        ),
        placeInfo: initialLocation,
      );
    }
    log.info('LocationPicker initialized with default location');
    // Fetch current location asynchronously
    Future.microtask(() => fetchCurrentLocation());
    return const LocationPickerState(selectedLocation: defaultLocation);
  }

  /// Fetches the current GPS location and updates the state.
  Future<void> fetchCurrentLocation() async {
    try {
      log.info('Fetching current GPS location');
      final location = await _locationService.retrieveCurrentLocation();
      final newLatLng = LatLng(location.latitude, location.longitude);
      state = state.copyWith(selectedLocation: newLatLng, placeInfo: location);
      log.info('Current location fetched: ${location.city}');
    } catch (e) {
      log.warning('Failed to fetch current location: $e');
      // Keep default/initial location on error
    }
  }

  /// Updates the selected location and fetches PlaceInfo for the given LatLng.
  Future<void> updateLocation(LatLng latLng) async {
    log.info('Updating location to: ${latLng.latitude}, ${latLng.longitude}');
    state = state.copyWith(
      selectedLocation: latLng,
      clearPlaceInfo: true,
      isLoading: true,
    );

    try {
      final placeInfo = await _locationService.getCurrentLocation(
        latLng.latitude,
        latLng.longitude,
      );
      state = state.copyWith(placeInfo: placeInfo, isLoading: false);
      log.info('Place info fetched: ${placeInfo.city}');
    } catch (e) {
      log.warning('Failed to fetch place info: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Moves to current GPS location.
  Future<LatLng?> moveToCurrentLocation() async {
    try {
      log.info('Moving to current GPS location');
      final location = await _locationService.retrieveCurrentLocation();
      final newLatLng = LatLng(location.latitude, location.longitude);
      state = state.copyWith(selectedLocation: newLatLng, placeInfo: location);
      return newLatLng;
    } catch (e) {
      log.warning('Failed to move to current location: $e');
      return null;
    }
  }
}
