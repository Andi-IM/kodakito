import 'package:latlong_to_place/latlong_to_place.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@riverpod
LocationService locationService(Ref ref) => LocationServiceImpl();

abstract class LocationService {
  Future<PlaceInfo> getCurrentLocation(double lat, double lng);
  Future<PlaceInfo> retrieveCurrentLocation();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<PlaceInfo> getCurrentLocation(double lat, double lng) async {
    final service = GeocodingService();
    final result = await service.getPlaceInfo(lat, lng);
    return result;
  }

  @override
  Future<PlaceInfo> retrieveCurrentLocation() async {
    final service = GeocodingService();
    final result = await service.getCurrentPlaceInfo();
    return result;
  }
}
