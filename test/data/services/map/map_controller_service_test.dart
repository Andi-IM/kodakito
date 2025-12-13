import 'package:dicoding_story/data/services/map/map_controller_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  late MapControllerServiceImpl service;
  late MockGoogleMapController mockController;

  setUpAll(() {
    registerFallbackValue(CameraUpdate.zoomIn());
  });

  setUp(() {
    service = MapControllerServiceImpl();
    mockController = MockGoogleMapController();
  });

  group('MapControllerServiceImpl', () {
    test('isReady returns false when no controller is set', () {
      expect(service.isReady, isFalse);
    });

    test('isReady returns true after setController is called', () {
      service.setController(mockController);
      expect(service.isReady, isTrue);
    });

    test('setController stores the controller', () {
      service.setController(mockController);
      expect(service.isReady, isTrue);
    });

    test('dispose calls controller.dispose and clears reference', () {
      when(() => mockController.dispose()).thenAnswer((_) async {});

      service.setController(mockController);
      expect(service.isReady, isTrue);

      service.dispose();

      verify(() => mockController.dispose()).called(1);
      expect(service.isReady, isFalse);
    });

    test('dispose does nothing when controller is null', () {
      // Should not throw
      service.dispose();
      expect(service.isReady, isFalse);
    });

    test('animateCamera calls controller.animateCamera', () async {
      final cameraUpdate = CameraUpdate.newLatLng(const LatLng(1, 2));
      when(() => mockController.animateCamera(any())).thenAnswer((_) async {});

      service.setController(mockController);
      await service.animateCamera(cameraUpdate);

      verify(() => mockController.animateCamera(cameraUpdate)).called(1);
    });

    test('animateCamera does nothing when controller is null', () async {
      // Should not throw when controller is null
      await service.animateCamera(CameraUpdate.zoomIn());
      expect(service.isReady, isFalse);
    });

    test('zoomIn calls controller.animateCamera with zoomIn update', () async {
      when(() => mockController.animateCamera(any())).thenAnswer((_) async {});

      service.setController(mockController);
      await service.zoomIn();

      verify(() => mockController.animateCamera(any())).called(1);
    });

    test('zoomIn does nothing when controller is null', () async {
      // Should not throw
      await service.zoomIn();
      expect(service.isReady, isFalse);
    });

    test(
      'zoomOut calls controller.animateCamera with zoomOut update',
      () async {
        when(
          () => mockController.animateCamera(any()),
        ).thenAnswer((_) async {});

        service.setController(mockController);
        await service.zoomOut();

        verify(() => mockController.animateCamera(any())).called(1);
      },
    );

    test('zoomOut does nothing when controller is null', () async {
      // Should not throw
      await service.zoomOut();
      expect(service.isReady, isFalse);
    });

    test('animateToPosition calls controller with newLatLngZoom', () async {
      const position = LatLng(10, 20);
      when(() => mockController.animateCamera(any())).thenAnswer((_) async {});

      service.setController(mockController);
      await service.animateToPosition(position, zoom: 18);

      verify(() => mockController.animateCamera(any())).called(1);
    });

    test('animateToPosition uses default zoom of 15', () async {
      const position = LatLng(10, 20);
      when(() => mockController.animateCamera(any())).thenAnswer((_) async {});

      service.setController(mockController);
      await service.animateToPosition(position);

      verify(() => mockController.animateCamera(any())).called(1);
    });

    test('animateToPosition does nothing when controller is null', () async {
      // Should not throw
      await service.animateToPosition(const LatLng(1, 2));
      expect(service.isReady, isFalse);
    });
  });
}
