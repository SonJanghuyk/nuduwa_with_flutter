import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';

class MapPageController extends GetxController {
  var currentLocation = const LatLng(0, 0);

  final _mapController = Completer<GoogleMapController>();
  final markers = <MarkerId, Marker>{}.obs;
  var snapshotMarkers = <MarkerId, Marker>{};

  var center = const LatLng(0, 0);
  final isCreate = false.obs;

  Marker? newMarker;
  final newMarkerId = const MarkerId('newMarker');

  final meetings = <Meeting>[].obs;

  void convertMarkers() {
    markers.value = snapshotMarkers;
    if(newMarker != null) {
      markers[newMarkerId] = newMarker!;
    }
    
  }

  void listenerForMeetings() {
    debugPrint("리슨");
    final ref = FirebaseFirestore.instance.collection('meeting').withConverter(
          fromFirestore: Meeting.fromFirestore,
          toFirestore: (Meeting meeting, _) => meeting.toFirestore(),
        );
    ref.snapshots().listen((event) {
      final snapshotMeetings = <Meeting>[];
      snapshotMarkers = {};
      for (var doc in event.docs) {
        snapshotMeetings.add(doc.data());
        debugPrint("미팅: ${doc.data().title}");

        Marker marker = Marker(
          markerId: MarkerId(doc.data().id!),
          position: doc.data().location,
          infoWindow: InfoWindow(title: doc.data().title),
        );

        snapshotMarkers[MarkerId(doc.data().id!)] = marker;
      }
      meetings.value = snapshotMeetings;
      convertMarkers();
    });
    debugPrint("리슨");
  }

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

    if (newMarker == null) {
      return;
    }

    Marker updatedMarker = newMarker!.copyWith(
      positionParam: position.target,
    );
    newMarker = updatedMarker;
    convertMarkers();
  }

  void clickedMeetingCreateButton() {
    if (!isCreate.value) {
      isCreate.value = true;
      Marker marker = Marker(
        markerId: newMarkerId,
        position: center,
        draggable: false,
      );
      newMarker = marker;
    } else {
      isCreate.value = false;
      newMarker = null;
    }
    convertMarkers();
  }
}
