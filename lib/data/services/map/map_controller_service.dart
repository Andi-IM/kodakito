import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract service for controlling map operations.
/// This allows mocking GoogleMapController in widget tests.
abstract class MapControllerService {
  /// Returns true if the controller is ready for use.
  bool get isReady;

  /// Sets the underlying GoogleMapController.
  void setController(GoogleMapController controller);

  /// Disposes of the controller.
  void dispose();

  /// Animates the camera to a new position.
  Future<void> animateCamera(CameraUpdate cameraUpdate);

  /// Zooms in on the map.
  Future<void> zoomIn();

  /// Zooms out on the map.
  Future<void> zoomOut();

  /// Animates to a specific LatLng with zoom level.
  Future<void> animateToPosition(LatLng position, {double zoom = 15});
}

/// Default implementation that uses the real GoogleMapController.
class MapControllerServiceImpl implements MapControllerService {
  GoogleMapController? _controller;

  @override
  bool get isReady => _controller != null;

  @override
  void setController(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    await _controller?.animateCamera(cameraUpdate);
  }

  @override
  Future<void> zoomIn() async {
    await _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  @override
  Future<void> zoomOut() async {
    await _controller?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Future<void> animateToPosition(LatLng position, {double zoom = 15}) async {
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }
}
