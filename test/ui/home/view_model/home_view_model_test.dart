import 'package:dicoding_story/ui/home/view_model/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong_to_place/latlong_to_place.dart';

void main() {
  group('SelectedLocation', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      final state = container.read(selectedLocationProvider);
      expect(state, isNull);
    });

    test('setLocation updates state with PlaceInfo', () {
      final location = PlaceInfo(
        formattedAddress: 'Test Address',
        street: 'Test Street',
        locality: 'Test Locality',
        city: 'Test City',
        state: 'Test State',
        country: 'Test Country',
        postalCode: '12345',
        latitude: 1.0,
        longitude: 2.0,
      );

      container.read(selectedLocationProvider.notifier).setLocation(location);

      expect(container.read(selectedLocationProvider), location);
    });

    test('setLocation with null clears location', () {
      final location = PlaceInfo(
        formattedAddress: 'Test Address',
        street: 'Test Street',
        locality: 'Test Locality',
        city: 'Test City',
        state: 'Test State',
        country: 'Test Country',
        postalCode: '12345',
        latitude: 1.0,
        longitude: 2.0,
      );

      // Set location first
      container.read(selectedLocationProvider.notifier).setLocation(location);
      expect(container.read(selectedLocationProvider), isNotNull);

      // Set to null
      container.read(selectedLocationProvider.notifier).setLocation(null);
      expect(container.read(selectedLocationProvider), isNull);
    });

    test('clear resets state to null', () {
      final location = PlaceInfo(
        formattedAddress: 'Test Address',
        street: 'Test Street',
        locality: 'Test Locality',
        city: 'Test City',
        state: 'Test State',
        country: 'Test Country',
        postalCode: '12345',
        latitude: 1.0,
        longitude: 2.0,
      );

      // Set location first
      container.read(selectedLocationProvider.notifier).setLocation(location);
      expect(container.read(selectedLocationProvider), isNotNull);

      // Clear
      container.read(selectedLocationProvider.notifier).clear();
      expect(container.read(selectedLocationProvider), isNull);
    });
  });
}
