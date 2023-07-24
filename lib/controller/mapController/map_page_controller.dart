import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/controller/home_page_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_info_sheet.dart';
import 'dart:ui' as ui;

import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MapPageController extends GetxController {
  static MapPageController get instance => Get.find();

  final homepageController = HomePageController.instance;

  // Model Manager
  final firebaseService = FirebaseService.instance;

  // GoogleMap
  var _mapController = Completer<GoogleMapController>();
  final meetings = <String, ({Meeting meeting, Marker marker})>{}.obs;
  // 구글 지도에서 POI아이콘 삭제
  late final String mapStyle;

  // Location
  var currentLocation = const LatLng(0, 0);
  var center = const LatLng(0, 0);

  // Draw MapMarker Icons
  final drawIconOfMeeting = DrawIconOfMeeting(
      !kIsWeb ? 80.0 : 26.666, !kIsWeb ? 10.0 : 3.333, !kIsWeb ? 30.0 : 10.0);
  late final Map<String, ui.Image> iconFrames;
  late final Map<String, BitmapDescriptor> loadingIcons;

  // Firestore Listener
  final snapshotMeetings = <String, ({Meeting meeting, Marker marker})>{};
  final listener = <String, StreamSubscription<QuerySnapshot<Member>>>{};

  // CreateMeeting
  final isCreate = false.obs;
  Marker? newMarker;
  final newMarkerId = 'newMeeting';

  // JoinMeeting
  final isLoading = false.obs;

  // Members
  final members = <Member>[].obs;

  // Category Filter
  final category = '필터'.obs;

  // MeetingInfoSheet
  final hostImage = Rx<ImageProvider?>(null);

  MapPageController();

  @override
  void onInit() async {
    super.onInit();
    debugPrint('맵맵맵');
    

    mapStyle = await  rootBundle.loadString('assets/map_style.txt');
    await _drawIconImages();

    _listenerForMeetingsOfMap();
  }

  @override
  void onReady() {
    ever(homepageController.userMeetings, _updateMeetingIcon);
    ever(homepageController.leavedMeeting, _updateMeetingIcon);
    once(homepageController.currentLatLng, fetchcurrentLocation);
  }

  void fetchcurrentLocation(LatLng? currentLocation){
    this.currentLocation = currentLocation!;
    center = currentLocation;
  }

  /// 모임 참여하거나 나가면 아이콘 색 바꾸기
  Future<void> _updateMeetingIcon(List<UserMeeting?> userMeetings) async {
    debugPrint('updateMeetingIcon');
    if (userMeetings.isEmpty) return;
    for (final userMeeting in userMeetings) {
      if (snapshotMeetings.keys.contains(userMeeting!.meetingId)) {
        fetchMeetingIcon(snapshotMeetings[userMeeting.meetingId]!.meeting);
      }
    }
  }

  /// 서버에서 가져오는 모임 데이터와 모임 만들기 때 생성되는 마커 합치기
  void _convertMeetings() {
    meetings.value = Map.from(snapshotMeetings);
    if (newMarker != null) {
      final tempMeeting = MeetingRepository.instance.tempMeetingData();
      meetings[newMarkerId] = (meeting: tempMeeting, marker: newMarker!);
    }
  }

  /// 지도에 보여줄 아이콘 이미지 미리 만들어놓기
  Future<void> _drawIconImages() async {
    // 여러 색깔 아이콘 이미지
    final framesWithColor = await Future.wait([
      for (final color in IconColors.values)
        drawIconOfMeeting.drawIconFrame(color.color)
    ]);
    iconFrames = Map.fromIterables(
        IconColors.values.map((e) => e.name), framesWithColor);

    // 웹 이미지 가져오는동안 보여줄 아이콘
    loadingIcons = await drawIconOfMeeting.drawLoadingIcons(iconFrames);
  }

  /// 서버에서 실시간으로 모임 데이터 & 모임 마커 가져오기
  void _listenerForMeetingsOfMap() {
    final ref = firebaseService.meetingList;
    final listener = ref.snapshots().listen((snapshot) {
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

          final meeting = doc.data();

          // Host 여부, 참여 여부에 따라 다른색 아이콘
          final loadingIcon = meeting.hostUid == firebaseService.currentUid
              ? loadingIcons[IconColors.host.name]
              : homepageController.userMeetings
                      .where(
                          (userMeeting) => userMeeting.meetingId == meeting.id)
                      .toList()
                      .isNotEmpty
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
          snapshotMeetings[meetingId] =
              (meeting: meeting, marker: markerForLoading);

          // 웹이미지 다 가져오면 마커표시
          fetchMeetingIcon(meeting);
        } catch (e) {
          debugPrint('리스너에러!!: $e');
          continue;
        }
      }
      _convertMeetings();
    });
    firebaseService.addListener(ref: ref, listener: listener);
    debugPrint("리슨");
  }

  // Host 정보 가져와서 모임 데이터에 이미지 넣기
  Future<void> fetchMeetingIcon(Meeting meeting) async {
    debugPrint('시작!fetchHostData');
    try {
      // Host 정보 가져오기
      if (meeting.hostName == null) {
        meeting = await MeetingRepository.instance.fetchHostData(meeting);
      }

      // 가져온 Host Image로 Icon 교체
      // Host 여부, 참여 여부에 따라 다른색 아이콘
      final iconColor = meeting.hostUid == firebaseService.currentUid!
          ? IconColors.host.name
          : homepageController.userMeetings
                  .where((userMeeting) => userMeeting.meetingId == meeting.id)
                  .toList()
                  .isNotEmpty
              ? IconColors.join.name
              : IconColors.defalt.name;

      // Marker 이미지를 HostImage로 교체
      final icon = await drawIconOfMeeting.drawMeetingIcon(
          meeting.hostImageUrl!, iconFrames[iconColor]!);

      // Web이미지로 마커 새로 그리기
      var marker = Marker(
        markerId: MarkerId(meeting.id!),
        position: meeting.location,
        icon: icon,
        onTap: () => meetingInfoSheet(meeting.id!),
      );
      snapshotMeetings[meeting.id!] = (meeting: meeting, marker: marker);
      // meetings[meeting.id!] = (meeting, marker);
      _convertMeetings();
    } catch (e) {
      debugPrint('에러!fetchHostData: ${e.toString()}');
      rethrow;
    }
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
    try {
      _mapController = Completer<GoogleMapController>();
      _mapController.complete(controller);

      controller.setMapStyle(mapStyle);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 지도 이동시 수행
  void checkedCenter(CameraPosition position) {
    center = position.target;

    if (newMarker == null) return;

    Marker updatedMarker = newMarker!.copyWith(
      positionParam: position.target,
    );
    newMarker = updatedMarker;
    _convertMeetings();
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
    _convertMeetings();
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
    try {
      await MemberRepository.instance.createMemberData(
          memberUid: firebaseService.currentUid!,
          meetingId: meetingId,
          hostUid: hostUid);
      Get.back();
      Get.snackbar(
        '모임참여 성공',
        '모임에 참여하였습니다',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  // 카테고리 필터
  void clickedFilter(MeetingCategory? category) {
    this.category.value = category?.displayName ?? '필터';
    for (var meeting in snapshotMeetings.values) {
      final visible = (category == null)
          ? true
          : meeting.meeting.category == category.displayName;
      Marker updatedMarker = meeting.marker.copyWith(visibleParam: visible);
      snapshotMeetings[meeting.meeting.id!] =
          (meeting: meeting.meeting, marker: updatedMarker);
    }
    _convertMeetings();
  }

  Future<void> downloadHostImage(String? url) async {
    if (url == null) hostImage.value = const AssetImage(Assets.imageNoImage);
    final imageBytes = await DrawIconOfMeeting.downloadImage(url);
    hostImage.value = Image.memory(imageBytes).image;
  }
}

enum IconColors {
  host(Colors.red),
  join(Colors.green),
  defalt(Colors.blue);

  final Color color;
  const IconColors(this.color);
}
