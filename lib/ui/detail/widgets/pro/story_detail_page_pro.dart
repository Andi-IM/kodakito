import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoryDetailPagePro extends StatefulWidget {
  final String id;
  const StoryDetailPagePro({super.key, required this.id});

  @override
  State<StoryDetailPagePro> createState() => _StoryDetailPageProState();
}

class _StoryDetailPageProState extends State<StoryDetailPagePro> {
  final dicodingOffice = const LatLng(-6.8957473, 107.6337669);
  final markers = <Marker>{};
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    final marker = Marker(
      markerId: const MarkerId("dicoding"),
      position: dicodingOffice,
      onTap: () {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(dicodingOffice, 18),
        );
      },
    );
    markers.add(marker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: dicodingOffice,
                zoom: 18,
              ),
              onMapCreated: (GoogleMapController controller) =>
                  mapController = controller,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: "zoom-in",
                    onPressed: () =>
                        mapController.animateCamera(CameraUpdate.zoomIn()),
                    child: const Icon(Icons.add),
                  ),
                  FloatingActionButton.small(
                    heroTag: "zoom-out",
                    onPressed: () =>
                        mapController.animateCamera(CameraUpdate.zoomOut()),
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
