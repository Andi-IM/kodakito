import 'package:dicoding_story/ui/home/view_model/location_picker_view_model.dart';
import 'package:dicoding_story/data/services/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  group('LocationPickerState', () {
    test('can be instantiated with required parameters', () {
      const state = LocationPickerState(selectedLocation: LatLng(0, 0));

      expect(state.selectedLocation, equals(const LatLng(0, 0)));
      expect(state.placeInfo, isNull);
      expect(state.isLoading, isFalse);
    });

    test('can be instantiated with all parameters', () {
      final placeInfo = PlaceInfo(
        formattedAddress: 'Test',
        street: 'Street',
        locality: 'Locality',
        city: 'City',
        state: 'State',
        country: 'Country',
        postalCode: '12345',
        latitude: 1.0,
        longitude: 2.0,
      );

      final state = LocationPickerState(
        selectedLocation: const LatLng(1, 2),
        placeInfo: placeInfo,
        isLoading: true,
      );

      expect(state.selectedLocation, equals(const LatLng(1, 2)));
      expect(state.placeInfo, equals(placeInfo));
      expect(state.isLoading, isTrue);
    });

    test('copyWith updates selectedLocation', () {
      const state = LocationPickerState(selectedLocation: LatLng(0, 0));
      final newState = state.copyWith(selectedLocation: const LatLng(1, 1));

      expect(newState.selectedLocation, equals(const LatLng(1, 1)));
    });

    test('copyWith updates placeInfo', () {
      const state = LocationPickerState(selectedLocation: LatLng(0, 0));
      final placeInfo = PlaceInfo(
        formattedAddress: 'Test',
        street: 'Street',
        locality: 'Locality',
        city: 'City',
        state: 'State',
        country: 'Country',
        postalCode: '12345',
        latitude: 1.0,
        longitude: 2.0,
      );

      final newState = state.copyWith(placeInfo: placeInfo);

      expect(newState.placeInfo, equals(placeInfo));
    });

    test('copyWith with clearPlaceInfo clears placeInfo', () {
      final placeInfo = PlaceInfo(
        formattedAddress: 'Test',
        street: 'Street',
        locality: 'Locality',
        city: 'City',
        state: 'State',
        country: 'Country',
        postalCode: '12345',
        latitude: 1.0,
        longitude: 2.0,
      );
      final state = LocationPickerState(
        selectedLocation: const LatLng(0, 0),
        placeInfo: placeInfo,
      );

      final newState = state.copyWith(clearPlaceInfo: true);

      expect(newState.placeInfo, isNull);
    });

    test('copyWith updates isLoading', () {
      const state = LocationPickerState(selectedLocation: LatLng(0, 0));
      final newState = state.copyWith(isLoading: true);

      expect(newState.isLoading, isTrue);
    });
  });

  group('LocationPicker provider', () {
    late MockLocationService mockLocationService;
    late ProviderContainer container;

    final testPlaceInfo = PlaceInfo(
      formattedAddress: 'Test Address',
      street: 'Test Street',
      locality: 'Test Locality',
      city: 'Test City',
      state: 'Test State',
      country: 'Test Country',
      postalCode: '12345',
      latitude: -6.2,
      longitude: 106.8,
    );

    setUp(() {
      mockLocationService = MockLocationService();
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(mockLocationService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state with null initialLocation uses default location', () {
      when(
        () => mockLocationService.retrieveCurrentLocation(),
      ).thenAnswer((_) async => testPlaceInfo);

      final state = container.read(locationPickerProvider(null));

      expect(state.selectedLocation, equals(LocationPicker.defaultLocation));
      expect(state.placeInfo, isNull);
    });

    test('initial state with initialLocation uses provided location', () {
      when(
        () => mockLocationService.retrieveCurrentLocation(),
      ).thenAnswer((_) async => testPlaceInfo);

      final state = container.read(locationPickerProvider(testPlaceInfo));

      expect(
        state.selectedLocation,
        equals(LatLng(testPlaceInfo.latitude, testPlaceInfo.longitude)),
      );
      expect(state.placeInfo, equals(testPlaceInfo));
    });

    test('updateLocation updates state and fetches placeInfo', () async {
      when(
        () => mockLocationService.retrieveCurrentLocation(),
      ).thenAnswer((_) async => testPlaceInfo);
      when(
        () => mockLocationService.getCurrentLocation(any(), any()),
      ).thenAnswer((_) async => testPlaceInfo);

      container.listen(locationPickerProvider(null), (_, __) {});

      await container
          .read(locationPickerProvider(null).notifier)
          .updateLocation(const LatLng(1, 2));

      final state = container.read(locationPickerProvider(null));

      expect(state.selectedLocation, equals(const LatLng(1, 2)));
      expect(state.placeInfo, equals(testPlaceInfo));
      expect(state.isLoading, isFalse);
      verify(() => mockLocationService.getCurrentLocation(1, 2)).called(1);
    });

    test('moveToCurrentLocation returns new LatLng on success', () async {
      when(
        () => mockLocationService.retrieveCurrentLocation(),
      ).thenAnswer((_) async => testPlaceInfo);

      container.listen(locationPickerProvider(null), (_, __) {});

      final result = await container
          .read(locationPickerProvider(null).notifier)
          .moveToCurrentLocation();

      expect(result, isNotNull);
      expect(
        result,
        equals(LatLng(testPlaceInfo.latitude, testPlaceInfo.longitude)),
      );
    });

    test('moveToCurrentLocation returns null on error', () async {
      when(
        () => mockLocationService.retrieveCurrentLocation(),
      ).thenThrow(Exception('Location error'));

      container.listen(locationPickerProvider(null), (_, __) {});

      final result = await container
          .read(locationPickerProvider(null).notifier)
          .moveToCurrentLocation();

      expect(result, isNull);
    });

    test('fetchCurrentLocation updates state on success', () async {
      when(
        () => mockLocationService.retrieveCurrentLocation(),
      ).thenAnswer((_) async => testPlaceInfo);

      container.listen(locationPickerProvider(null), (_, __) {});

      await container
          .read(locationPickerProvider(null).notifier)
          .fetchCurrentLocation();

      final state = container.read(locationPickerProvider(null));

      expect(
        state.selectedLocation,
        equals(LatLng(testPlaceInfo.latitude, testPlaceInfo.longitude)),
      );
      expect(state.placeInfo, equals(testPlaceInfo));
    });
  });
}
