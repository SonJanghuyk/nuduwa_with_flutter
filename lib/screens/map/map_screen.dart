import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(37.4036, 126.9304);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('대림대'),
            position: LatLng(37.4036, 126.9304),
          ),
        },
      ),
    );
  }
}
