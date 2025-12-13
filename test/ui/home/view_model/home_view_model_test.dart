import 'package:dicoding_story/ui/home/view_model/add_story_state.dart';
import 'package:dicoding_story/ui/home/view_model/home_view_model.dart';
import 'package:dicoding_story/ui/home/view_model/stories_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:latlong_to_place/latlong_to_place.dart';

void main() {
  group('SelectedLocation', () {
    // ... existing tests ...
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

  group('generated code coverage', () {
    test('SelectedLocationProvider overrideWithValue returns Override', () {
      final override = selectedLocationProvider.overrideWithValue(null);
      expect(override, isNotNull);
    });

    test('SelectedPhotoFileProvider overrideWithValue returns Override', () {
      final override = selectedPhotoFileProvider.overrideWithValue(null);
      expect(override, isNotNull);
    });

    test('ImageFileProvider overrideWithValue returns Override', () {
      final override = imageFileProvider.overrideWithValue(null);
      expect(override, isNotNull);
    });

    test(
      'getCroppedImageFromPickerProvider toString contains provider name and args',
      () {
        final stream = const Stream<InstaAssetsExportDetails>.empty();
        final provider = getCroppedImageFromPickerProvider(stream);
        expect(
          provider.toString(),
          contains('getCroppedImageFromPickerProvider'),
        );
      },
    );

    test('GetCroppedImageFromPickerFamily toString contains provider name', () {
      expect(
        getCroppedImageFromPickerProvider.toString(),
        contains('getCroppedImageFromPickerProvider'),
      );
    });

    test('StoriesNotifierProvider overrideWithValue returns Override', () {
      final override = storiesProvider.overrideWithValue(
        StoriesState.initial(),
      );
      expect(override, isNotNull);
    });

    test('AddStoryNotifierProvider overrideWithValue returns Override', () {
      final override = addStoryProvider.overrideWithValue(
        const AddStoryInitial(),
      );
      expect(override, isNotNull);
    });
  });
}
