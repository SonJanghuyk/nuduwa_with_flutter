import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_icon_image.dart';

import '../model/user.dart';

class MapPageController extends GetxController {
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
  final userManager = UserManager.instance;
  final meetingIcon = MeetingIconImage();

  var currentLocation = const LatLng(0, 0);

  var _mapController = Completer<GoogleMapController>();
  final markers = <MarkerId, Marker>{}.obs;
  var snapshotMarkers = <MarkerId, Marker>{};
  var iconImages = <String, Image>{};

  var center = const LatLng(0, 0);
  final isCreate = false.obs;

  Marker? newMarker;
  final newMarkerId = const MarkerId('newMarker');

  final meetings = <Meeting>[].obs;

  void convertMarkers() {    
    // markers.remove();
    markers.value = Map.from(snapshotMarkers);
    if (newMarker != null) {
      markers[newMarkerId] = newMarker!;
    }
    debugPrint('뉴마커: ${newMarker.toString()}');
    debugPrint('스냅샷마커: ${snapshotMarkers.toString()}');
    debugPrint('마커수: ${markers.length}');
    debugPrint('마커: ${markers.toString()}');
  }

  void listenerForMeetings() {
    debugPrint("리스너");
    final ref = FirebaseFirestore.instance.collection('meeting').withConverter(
          fromFirestore: Meeting.fromFirestore,
          toFirestore: (Meeting meeting, _) => meeting.toFirestore(),
        );
    ref.snapshots().listen((event) {
      debugPrint("지도모임리슨");
      final snapshotMeetings = <Meeting>[];
      snapshotMarkers.clear();
      for (var doc in event.docs) {
        if (!doc.exists){continue;}
        if (doc.metadata.hasPendingWrites){debugPrint('리스너!로컬');continue;}
        try{
          final data = doc.data();
          snapshotMeetings.add(data);        

          final iconColor = data.hostUID == currentUid ? Colors.red : Colors.blue;

          meetingIcon.meetingIcon(null, iconColor).then((loadingIcon) {
            debugPrint('모임: ${data.title}');
            var markerForLoading = Marker(
              markerId: MarkerId(data.id!),
              position: data.location,
              icon: loadingIcon,
            );
            snapshotMarkers[MarkerId(data.id!)] = markerForLoading;
            convertMarkers();

            
            userManager.fetchUser(data.hostUID).then((user) {
              if (user == null) {return;}
              data.hostName = user.name;
              data.hostImage = user.image;

              debugPrint('이미지:${data.hostImage}');

              if (data.hostImage != null) {
                meetingIcon.meetingIcon(data.hostImage, iconColor)
                    .then((webIcon) {
                  var marker = Marker(
                    markerId: MarkerId(data.id!),
                    position: data.location,
                    icon: webIcon,
                  );
                  debugPrint('이미지추가완료!');
                  snapshotMarkers[MarkerId(data.id!)] = marker;
                  convertMarkers();
                });
              }

            }).printError();
          }).onError((error, stackTrace) {
            debugPrint('에러!!!!!${error.toString()}');
          });
        }catch(e){
          debugPrint('리스너에러!!: $e');
        }
      }
      debugPrint('모임들: ${snapshotMarkers.toString()}');
      // meetings.value = snapshotMeetings;
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
    _mapController = Completer<GoogleMapController>();
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
