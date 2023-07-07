import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_icon_image.dart';

import '../model/user.dart';

class MapPageController extends GetxController {
  // CurrentUID
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Model Manager
  final userManager = UserManager.instance;
  final meetingManager = MeetingManager.instance;

  // GoogleMap
  var _mapController = Completer<GoogleMapController>();
  final meetings = <String, (Meeting, Marker)>{}.obs;

  // Location
  var currentLocation = const LatLng(0, 0);
  var center = const LatLng(0, 0);

  // MapMarker Icon
  final meetingIcon = MeetingIconImage();

  // Firestore Listener
  var snapshotMeetings = <String, (Meeting, Marker)>{};

  // CreateMeeting
  final isCreate = false.obs;
  Marker? newMarker;
  final newMarkerId = 'newMeeting';

  MapPageController(LatLng? location)
      : currentLocation = location ?? const LatLng(0, 0);

  @override
  void onInit() {
    super.onInit();
    center = currentLocation;
    listenerForMeetings2();
  }

  void convertMeetings() {
    meetings.value = Map.from(snapshotMeetings);
    if (newMarker != null) {
      final temp = Meeting(
          title: '',
          description: '',
          place: '',
          maxMemers: 0,
          category: '',
          location: const LatLng(0, 0),
          meetingTime: DateTime.now(),
          hostUid: '');
      meetings[newMarkerId] = (temp, newMarker!);
    }
  }

  void listenerForMeetings() {
    debugPrint("리스너");
    final ref = FirebaseFirestore.instance.collection('meeting').withConverter(
          fromFirestore: Meeting.fromFirestore,
          toFirestore: (Meeting meeting, _) => meeting.toFirestore(),
        );
    ref.snapshots().listen((snapshot) {
      debugPrint("지도모임리슨");
      snapshotMeetings.clear();

      for (var doc in snapshot.docs) {
        try {
          if (!doc.exists || doc.metadata.hasPendingWrites) {
            debugPrint('리스너! 에러 또는 로컬');
            continue;
          }

          final meetingId = doc.id;

          if (meetings.containsKey(meetingId)) {
            snapshotMeetings[meetingId] = meetings[meetingId]!;
            continue;
          }

          final meeting = doc.data();
          final iconColor =
              meeting.hostUid == currentUid ? Colors.red : Colors.blue;

          meetingIcon.meetingIcon(null, iconColor).then((loadingIcon) {
            var markerForLoading = Marker(
              markerId: MarkerId(meetingId),
              position: meeting.location,
              icon: loadingIcon,
            );
            snapshotMeetings[meetingId] = (meeting, markerForLoading);

            userManager.fetchUser(meeting.hostUid).then((user) {
              if (user == null) {
                return;
              }
              meeting.hostName = user.name;
              meeting.hostImage = user.image;

              if (meeting.hostImage == null) {
                return;
              }

              meetingIcon
                  .meetingIcon(meeting.hostImage, iconColor)
                  .then((webIcon) {
                var marker = Marker(
                  markerId: MarkerId(meeting.id!),
                  position: meeting.location,
                  icon: webIcon,
                );
                debugPrint('이미지추가완료!');
                snapshotMeetings[meetingId] = (meeting, marker);
              });
            });
          });
        } catch (e) {
          debugPrint('리스너에러!!: $e');
          continue;
        }
      }
      convertMeetings();
    });
    debugPrint("리슨");
  }

  void listenerForMeetings2() {
    debugPrint("리스너");
    meetingManager.meetingList.snapshots().listen((snapshot) async {
      debugPrint("지도모임리스너");
      snapshotMeetings.clear();

      final loadingIcons = await Future.wait([
        meetingIcon.meetingIcon(null, Colors.red),
        meetingIcon.meetingIcon(null, Colors.green),
        meetingIcon.meetingIcon(null, Colors.blue),
      ]);

      final loadingIconForCurrent = loadingIcons[0];
      final loadingIconForJoin = loadingIcons[1];
      final loadingIconForDefault = loadingIcons[2];

      for (var doc in snapshot.docs) {
        try {
          // 데이터가 없거나 로컬 데이터이면 contiue
          if (!doc.exists || doc.metadata.hasPendingWrites) continue;

          // 이미 불러온 데이터면 가져와서 continue
          final meetingId = doc.id;
          if (meetings.containsKey(meetingId)) {
            snapshotMeetings[meetingId] = meetings[meetingId]!;
            convertMeetings();
            continue;
          }

          final meeting = doc.data();
          final loadingIcon = meeting.hostUid == currentUid
              ? loadingIconForCurrent
              : loadingIconForDefault;

          // 우선 로딩아이콘으로 마커표시
          var markerForLoading = Marker(
            markerId: MarkerId(meetingId),
            position: meeting.location,
            icon: loadingIcon,
          );
          snapshotMeetings[meetingId] = (meeting, markerForLoading);

          fetchHostData(meeting);
        } catch (e) {
          debugPrint('리스너에러!!: $e');
          continue;
        }
      }
      convertMeetings();
    });
    debugPrint("리슨");
  }

  Future<void> fetchHostData(Meeting meeting) async {
    debugPrint('시작!fetchHostData');
    try {
      // Host 정보 가져오기
      final host = await userManager.fetchUser(meeting.hostUid);
      if (host == null) return;

      meeting.hostName = host.name;
      meeting.hostImage = host.image;

      // Marker 이미지를 HostImage로 교체
      if (meeting.hostImage == null) return;

      final iconColor =
          meeting.hostUid == currentUid ? Colors.red : Colors.blue;
      final webIcon =
          await meetingIcon.meetingIcon(meeting.hostImage, iconColor);
      var marker = Marker(
        markerId: MarkerId(meeting.id!),
        position: meeting.location,
        icon: webIcon,
      );
      meetings[meeting.id!] = (meeting, marker);
      debugPrint('끝!fetchHostData');
    } catch (e) {
      debugPrint('에러!fetchHostData');
      rethrow;
    }
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
    convertMeetings();
  }

  void clickedMeetingCreateButton() {
    if (!isCreate.value) {
      isCreate.value = true;
      Marker marker = Marker(
        markerId: MarkerId(newMarkerId),
        position: center,
        draggable: false,
      );
      newMarker = marker;
    } else {
      isCreate.value = false;
      newMarker = null;
    }
    convertMeetings();
  }
}
