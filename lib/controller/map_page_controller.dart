import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPageController extends GetxController {
  var currentLocation = const LatLng(0, 0);

  final _mapController = Completer<GoogleMapController>();
  final markers = <MarkerId, Marker>{}.obs;
  var center = const LatLng(0, 0);
  final isCreate = false.obs;

  final newMarkerId = const MarkerId('newMarker');

  void setCurrentLocation(LatLng? currentLatLng) {
    if (currentLatLng == null) {
      return;
    }
    currentLocation = currentLatLng;
    center = currentLatLng;
  }

  Future<void> moveCurrentLatLng() async {
    GoogleMapController controller = await _mapController.future;
    final currentPosition = await Geolocator.getCurrentPosition();

    currentLocation =
        LatLng(currentPosition.latitude, currentPosition.longitude);

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentLocation,
        zoom: 15.0,
      ),
    ));
  }

  void onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);

    // 구글 지도에서 POI아이콘 삭제
    rootBundle.loadString('assets/map_style.txt').then((value) {
      controller.setMapStyle(value);
    });
  }

  void checkedCenter(CameraPosition position) {
    center = position.target;

    if (markers[newMarkerId] != null) {
      Marker marker = markers[newMarkerId]!;
      Marker updatedMarker = marker.copyWith(
        positionParam: position.target,
      );
      markers[newMarkerId] = updatedMarker;
    }
  }

  void clickedMeetingCreateButton() {
    if (!isCreate.value) {
      isCreate.value = true;
      Marker marker = Marker(
        markerId: newMarkerId,
        position: center,
        draggable: false,
      );
      markers[newMarkerId] = marker;
    } else {
      isCreate.value = false;
      markers.remove(newMarkerId);
    }
  }

  // String markerIdVal({bool increment = false}) {
  //   String val = 'marker_id_$_markerIdCounter';
  //   if (increment) _markerIdCounter++;
  //   return val;
  // }
/*
  loadMarkers() async {
    markers.add(Marker(
        markerId: MarkerId('대림대'),
        position: LatLng(37.4036, 126.9304),
        icon: await meetingIcon(),
        infoWindow: InfoWindow(title: '대림대학교'),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15.0),
              ),
            ),
            barrierColor: Colors.white.withOpacity(0),
            isScrollControlled: true,
            builder: (BuildContext context) => const MeetingInfoSheet(),
          );
        }));
    markers.add(
      Marker(
        markerId: MarkerId('안양대'),
        position: LatLng(37.3919, 126.9199),
        icon: await meetingIcon(),
        infoWindow: InfoWindow(title: '안양대학교'),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId('안양종합운동장'),
        position: LatLng(37.4053, 126.9464),
        infoWindow: InfoWindow(title: '안양종합운동장'),
      ),
    );
  }
  */
}
