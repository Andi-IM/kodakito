import 'package:dicoding_story/data/services/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('locationServiceProvider', () {
    test('returns a LocationServiceImpl instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(locationServiceProvider);

      expect(result, isA<LocationServiceImpl>());
    });

    test('returns a LocationService instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(locationServiceProvider);

      expect(result, isA<LocationService>());
    });
  });
}
