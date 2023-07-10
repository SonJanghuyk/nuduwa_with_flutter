import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_info_sheet.dart';
import 'dart:ui' as ui;

import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MapPageController extends GetxController {
  static MapPageController get instance => Get.find();

  // Model Manager
  final firebaseService = FirebaseService.instance;

  // GoogleMap
  var _mapController = Completer<GoogleMapController>();
  final meetings = <String, (Meeting, Marker)>{}.obs;

  // Location
  var currentLocation = const LatLng(0, 0);
  var center = const LatLng(0, 0);

  // Draw MapMarker Icons
  final iconOfMeeting = DrawIconOfMeeting(80.0, 10.0, 30.0);
  late final Map<String, ui.Image> iconImages;
  late final Map<String, BitmapDescriptor> loadingIcons;

  // Firestore Listener
  final snapshotMeetings = <String, (Meeting, Marker)>{};
  final listener = <String, StreamSubscription<QuerySnapshot<Member>>>{};

  // CreateMeeting
  final isCreate = false.obs;
  Marker? newMarker;
  final newMarkerId = 'newMeeting';

  // JoinMeeting
  final isLoading = false.obs;

  // Members
  final members = <Member>[].obs;

  // UserMeeting
  RxList<UserMeeting> userMeetings;

  MapPageController({required LatLng? location, required this.userMeetings}) {
    currentLocation = location ?? const LatLng(0, 0);
  }

  @override
  void onInit() async {
    debugPrint("MapPageController");
    super.onInit();
    center = currentLocation;
    await drawIconImages();
    listenerForMeetingsOfMap();
  }

  // 서버에서 가져오는 모임 데이터와 모임 만들기 때 생성되는 마커 합치기
  void convertMeetings() {
    meetings.value = Map.from(snapshotMeetings);
    if (newMarker != null) {
      final tempMeeting = firebaseService.tempMeetingData();
      meetings[newMarkerId] = (tempMeeting, newMarker!);
    }
  }

  Future<void> drawIconImages() async {
    // 여러 색깔 아이콘 이미지
    final imagesWithColor = await Future.wait([
      for (final color in IconColors.values) iconOfMeeting.drawIconImage(color.color)
    ]);    
    iconImages = Map.fromIterables(IconColors.values.map((e) => e.name), imagesWithColor);

    // 웹 이미지 가져오는동안 보여줄 아이콘
    loadingIcons = await iconOfMeeting.drawLoadingIcons(iconImages);
  }

  /// 서버에서 실시간으로 모임 데이터 & 모임 마커 가져오기
  void listenerForMeetingsOfMap() {
    debugPrint("listenerForMeetings");   
    
    firebaseService.meetingList.snapshots().listen((snapshot) {
      debugPrint("지도모임리스너");
      snapshotMeetings.clear();      

      for (final doc in snapshot.docs) {
        try {
          // 데이터가 없거나 로컬 데이터이면 contiue
          if (!doc.exists || doc.metadata.hasPendingWrites) continue;

          // 이미 불러온 데이터면 가져와서 continue
          final meetingId = doc.id;
          if (meetings.containsKey(meetingId)) {
            snapshotMeetings[meetingId] = meetings[meetingId]!;
            continue;
          }
          debugPrint('모임: ${doc.data().title}');

          final meeting = doc.data();

          // Host 여부, 참여 여부에 따라 다른색 아이콘
          final loadingIcon = meeting.hostUid == firebaseService.currentUid
              ? loadingIcons[IconColors.host.name]
              : userMeetings.where((userMeeting) => userMeeting.meetingId == meeting.id).toList().isNotEmpty
                  ? loadingIcons[IconColors.join.name]
                  : loadingIcons[IconColors.defalt.name];

          // 우선 로딩아이콘으로 마커표시
          var markerForLoading = Marker(
            markerId: MarkerId(meetingId),
            position: meeting.location,
            icon: loadingIcon!,
            onTap: () {
              if (meetings[meetingId] != null) {
                meetingInfoSheet(meetingId);
              }
            },
          );
          snapshotMeetings[meetingId] = (meeting, markerForLoading);

          // 웹이미지 다 가져오면 마커표시
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

  // Host 정보 가져와서 모임 데이터에 이미지 넣기
  Future<void> fetchHostData(Meeting meeting) async {
    debugPrint('시작!fetchHostData');
    try {
      // Host 정보 가져오기
      meeting = await firebaseService.fetchHostData(meeting);

      // 가져온 Host Image로 Icon 교체
      updateMeetingIcon(meeting);
      
    } catch (e) {
      debugPrint('에러!fetchHostData: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateMeetingIcon(Meeting meeting) async {
    // Host 여부, 참여 여부에 따라 다른색 아이콘
    final iconColor = meeting.hostUid == firebaseService.currentUid!
          ? IconColors.host.name
          : userMeetings.where((userMeeting) => userMeeting.meetingId == meeting.id).toList().isNotEmpty
              ? IconColors.join.name        
              : IconColors.defalt.name;

    // Marker 이미지를 HostImage로 교체
    final icon = await iconOfMeeting.createIconImage(meeting.hostImageData!, iconImages[iconColor]!);

    // Web이미지로 마커 새로 그리기
      var marker = Marker(
        markerId: MarkerId(meeting.id!),
        position: meeting.location,
        icon: icon,
        onTap: () => meetingInfoSheet(meeting.id!),
      );
      snapshotMeetings[meeting.id!] = (meeting, marker);
      meetings[meeting.id!] = (meeting, marker);
      convertMeetings();
  }

  // 현재 위치로 지도 이동
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

  // 구글지도 초기화
  void onMapCreated(GoogleMapController controller) async {
    _mapController = Completer<GoogleMapController>();
    _mapController.complete(controller);

    // 구글 지도에서 POI아이콘 삭제
    rootBundle.loadString('assets/map_style.txt').then((value) {
      controller.setMapStyle(value);
    });
  }

  // 지도 이동시 수행
  void checkedCenter(CameraPosition position) {
    center = position.target;

    if (newMarker == null) return;

    Marker updatedMarker = newMarker!.copyWith(
      positionParam: position.target,
    );
    newMarker = updatedMarker;
    convertMeetings();
  }

  // 모임 만들기 클릭시 지도 중앙에 마커 생성
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

  // 모임 맴버 리스너시작
  void listenerForMembers(String meetingId) {
    debugPrint('모임맴버리스너!!!!');

    listener[meetingId] =
        firebaseService.memberList(meetingId).snapshots().listen((snapshot) {
      final snapshotMembers = snapshot.docs
          .where((doc) => doc.exists && !doc.metadata.hasPendingWrites)
          .map((doc) => doc.data())
          .toList();
      members.value = snapshotMembers;
    });
  }

  // 모임 맴버 리스너종료
  void cancelListenerForMembers(String meetingId) {
    debugPrint('모임맴버리스너종료!!');
    if (listener[meetingId] == null) return;
    listener[meetingId]!.cancel();
    listener.remove(meetingId);
  }

  // 모임 참여하기
  void joinMeeting(
      String meetingId, String hostUid, DateTime meetingTime) async {
    isLoading.value = true;
    debugPrint('로딩1: ${isLoading.value}');
    try {
      debugPrint('모임참여 성공0');
      await firebaseService.createMemberData(meetingId, hostUid, meetingTime);
      debugPrint('모임참여 성공1');
      Get.back();
      debugPrint('모임참여 성공2');
      Get.snackbar(
        '모임참여 성공',
        '모임에 참여하였습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('모임참여 성공3');
      isLoading.value = false;
    } catch (e) {
      debugPrint('모임참여 실패 ${e.toString()}');
      Get.snackbar(
        '모임참여 실패',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      isLoading.value = false;
    }
  }

  
}

enum IconColors {
  host(Colors.red),
  join(Colors.green),
  defalt(Colors.blue);

  final Color color;
  const IconColors(this.color);
}