import 'package:dicoding_story/data/services/platform/platform_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('webPlatformProvider', () {
    test('returns a bool value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(webPlatformProvider);

      expect(result, isA<bool>());
    });

    test('can be overridden with true', () {
      final container = ProviderContainer(
        overrides: [webPlatformProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      final result = container.read(webPlatformProvider);

      expect(result, isTrue);
    });

    test('can be overridden with false', () {
      final container = ProviderContainer(
        overrides: [webPlatformProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final result = container.read(webPlatformProvider);

      expect(result, isFalse);
    });
  });

  group('mobilePlatformProvider', () {
    test('returns a bool value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(mobilePlatformProvider);

      expect(result, isA<bool>());
    });

    test('can be overridden with true', () {
      final container = ProviderContainer(
        overrides: [mobilePlatformProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      final result = container.read(mobilePlatformProvider);

      expect(result, isTrue);
    });

    test('can be overridden with false', () {
      final container = ProviderContainer(
        overrides: [mobilePlatformProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final result = container.read(mobilePlatformProvider);

      expect(result, isFalse);
    });
  });

  group('supportMapsProvider', () {
    test('returns a bool value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(supportMapsProvider);

      expect(result, isA<bool>());
    });

    test('can be overridden with true', () {
      final container = ProviderContainer(
        overrides: [supportMapsProvider.overrideWithValue(true)],
      );
      addTearDown(container.dispose);

      final result = container.read(supportMapsProvider);

      expect(result, isTrue);
    });

    test('can be overridden with false', () {
      final container = ProviderContainer(
        overrides: [supportMapsProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final result = container.read(supportMapsProvider);

      expect(result, isFalse);
    });
  });
}
