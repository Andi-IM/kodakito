import 'package:dicoding_story/common/routing/app_router/go_router_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Routing constants', () {
    test('home constant has correct value', () {
      expect(Routing.home, equals('home'));
    });

    test('detail constant has correct value', () {
      expect(Routing.detail, equals('detail'));
    });

    test('post constant has correct value', () {
      expect(Routing.post, equals('post'));
    });

    test('crop constant has correct value', () {
      expect(Routing.crop, equals('crop'));
    });

    test('pickLocation constant has correct value', () {
      expect(Routing.pickLocation, equals('pick-location'));
    });

    test('login constant has correct value', () {
      expect(Routing.login, equals('login'));
    });

    test('register constant has correct value', () {
      expect(Routing.register, equals('register'));
    });

    test('settings constant has correct value', () {
      expect(Routing.settings, equals('settings'));
    });

    test('language constant has correct value', () {
      expect(Routing.language, equals('language'));
    });
  });

  group('PostStoryRouteExtra', () {
    test('can be instantiated with no parameters', () {
      const extra = PostStoryRouteExtra();

      expect(extra.cropStream, isNull);
      expect(extra.resetState, isNull);
    });

    test('can be instantiated with resetState callback', () {
      var callbackCalled = false;
      final extra = PostStoryRouteExtra(
        resetState: () => callbackCalled = true,
      );

      expect(extra.resetState, isNotNull);
      extra.resetState!();
      expect(callbackCalled, isTrue);
    });
  });

  group('Route classes', () {
    test('HomeScreenRoute can be instantiated', () {
      const route = HomeScreenRoute();
      expect(route, isA<HomeScreenRoute>());
    });

    test('DetailRoute can be instantiated with required parameters', () {
      const route = DetailRoute(id: 'test-id');
      expect(route.id, equals('test-id'));
      expect(route.hasLocation, isFalse);
    });

    test('DetailRoute can be instantiated with hasLocation=true', () {
      const route = DetailRoute(id: 'test-id', hasLocation: true);
      expect(route.id, equals('test-id'));
      expect(route.hasLocation, isTrue);
    });

    test('SettingsRoute can be instantiated', () {
      const route = SettingsRoute();
      expect(route, isA<SettingsRoute>());
    });

    test('LanguageRoute can be instantiated', () {
      const route = LanguageRoute();
      expect(route, isA<LanguageRoute>());
    });

    test('PostStoryRoute can be instantiated', () {
      const route = PostStoryRoute();
      expect(route, isA<PostStoryRoute>());
    });

    test('CropStoryImageRoute can be instantiated', () {
      const route = CropStoryImageRoute();
      expect(route, isA<CropStoryImageRoute>());
    });

    test('LocationPickerRoute can be instantiated', () {
      const route = LocationPickerRoute();
      expect(route, isA<LocationPickerRoute>());
    });

    test('LoginRoute can be instantiated', () {
      const route = LoginRoute();
      expect(route, isA<LoginRoute>());
    });

    test('RegisterRoute can be instantiated', () {
      const route = RegisterRoute();
      expect(route, isA<RegisterRoute>());
    });
  });
}
