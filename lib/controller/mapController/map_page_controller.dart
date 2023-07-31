import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/pages/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/pages/map/sub/meeting_info_sheet.dart';
import 'dart:ui' as ui;

import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/service/permission_service.dart';

class MapPageController extends GetxController {
  // static MapPageController get instance => Get.find();

  // Helper
  final utils = MapPageControllerUtils(
      drawIconOfMeeting: DrawIconOfMeeting(!kIsWeb ? 80.0 : 26.666,
          !kIsWeb ? 10.0 : 3.333, !kIsWeb ? 30.0 : 10.0));

  // GoogleMap
  final _mapController = Completer<GoogleMapController>();
  final meetingsAndMarkers =
      RxMap<String, ({Meeting meeting, Marker marker})>();
  var _checkUserMeetings = <UserMeeting>[];

  // 구글 지도에서 POI아이콘 삭제
  late final String _mapStyle;

  // Location
  final currentLatLng = Rx<LatLng?>(null);
  var center = const LatLng(0, 0);

  // Firestore Listener
  final _snapshotMeetingsAndMarkers =
      <String, ({Meeting meeting, Marker marker})>{};
  final _snapshotMeetings = RxList<Meeting>();

  // CreateMeeting
  final isCreate = RxBool(false);
  Marker? newMarker;
  final newMarkerId = 'newMeeting';

  // JoinMeeting
  final isLoading = RxBool(false);

  // Members
  final members = RxList<Member>();

  // Category Filter
  final category = RxString('필터');

  @override
  void onInit() async {
    super.onInit();

    await _initializeVariables();

    ever(MainPageController.instance.userMeetings, _updateMeetingIcon);
    once(PermissionService.instance.currentLatLng, fetchCurrentLocation);

    _snapshotMeetings.bindStream(_streamMeetings());
    ever(_snapshotMeetings, _createMarkers);
  }

  Future<void> _initializeVariables() async {
    // GoogleMap Style - Remove POI Icons
    _mapStyle = await rootBundle.loadString('assets/map_style.txt');

    currentLatLng.value = PermissionService.instance.currentLatLng.value;
  }

  void fetchCurrentLocation(LatLng? currentLatLng) {
    debugPrint('위치 권한');
    this.currentLatLng.value = currentLatLng;
    center = currentLatLng!;
  }

  /// 모임 참여하거나 나가면 아이콘 색 바꾸기
  Future<void> _updateMeetingIcon(List<UserMeeting> userMeetings) async {
    debugPrint('updateMeetingIcon');
    final leavedMeetings =
        _checkUserMeetings.toSet().difference(userMeetings.toSet());
    final joinMeetings =
        userMeetings.toSet().difference(_checkUserMeetings.toSet());
    final symmetricDifferenceMeetings = leavedMeetings.union(joinMeetings);

    _checkUserMeetings = userMeetings;

    for (final userMeeting in symmetricDifferenceMeetings) {
      if (_snapshotMeetingsAndMarkers.keys.contains(userMeeting.meetingId)) {
        final meeting =
            _snapshotMeetingsAndMarkers[userMeeting.meetingId]!.meeting;
        final marker = await utils.fetchMeetingMarker(meeting);
        _snapshotMeetingsAndMarkers[userMeeting.meetingId] =
            (meeting: meeting, marker: marker);
      }
    }
    _convertMeetings();
  }

  /// 서버에서 가져오는 모임 데이터와 모임 만들기 때 생성되는 마커 합치기
  void _convertMeetings() {
    meetingsAndMarkers.value = Map.from(_snapshotMeetingsAndMarkers);
    if (newMarker != null) {
      final tempMeeting = MeetingRepository.tempMeetingData();
      meetingsAndMarkers[newMarkerId] =
          (meeting: tempMeeting, marker: newMarker!);
    }
  }

  void clusteringMarkers() {}

  Stream<List<Meeting>> _streamMeetings() {
    return MeetingRepository.listenAllDocuments();
  }

  void _createMarkers(List<Meeting> meetings) {
    _snapshotMeetingsAndMarkers.clear();
    for (final meeting in meetings) {
      final markerForLoading = utils.creatLoadingMeetingMarker(meeting);

      // 우선 로딩아이콘으로 마커표시
      _snapshotMeetingsAndMarkers[meeting.id!] =
          (meeting: meeting, marker: markerForLoading);

      // Marker 이미지를 HostImage로 교체
      utils.fetchMeetingMarker(meeting).then((marker) {
        _snapshotMeetingsAndMarkers[meeting.id!] =
            (meeting: meeting, marker: marker);
        _convertMeetings();
      });
    }
    _convertMeetings();
  }

  // 현재 위치로 지도 이동
  Future<void> moveCurrentLatLng() async {
    try {
      GoogleMapController controller = await _mapController.future;

      final currentPosition = await Geolocator.getCurrentPosition();

      currentLatLng.value =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng.value!,
          zoom: 15.0,
        ),
      ));
    } on PermissionDeniedException {
      final check = await PermissionService.instance.checkLocationPermission();
      if (check != null) moveCurrentLatLng();
    } catch (e) {
      debugPrint('오류! moveCurrentLatLng: ${e.toString()}');
    }
  }

  // 구글지도 초기화
  void onMapCreated(GoogleMapController controller) async {
    try {
      // _mapController = Completer<GoogleMapController>();
      _mapController.complete(controller);

      controller.setMapStyle(_mapStyle);
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
  // void listenerForMembers(String meetingId) {
  //   debugPrint('모임맴버리스너!!!!');

  //   listener[meetingId] =
  //       FirebaseReference.memberList(meetingId).snapshots().listen((snapshot) {
  //     final snapshotMembers = snapshot.docs
  //         .where((doc) => doc.exists && !doc.metadata.hasPendingWrites)
  //         .map((doc) => doc.data())
  //         .toList();
  //     members.value = snapshotMembers;
  //   });
  // }

  // 모임 맴버 리스너종료
  // void cancelListenerForMembers(String meetingId) {
  //   debugPrint('모임맴버리스너종료!!');
  //   if (listener[meetingId] == null) return;
  //   listener[meetingId]!.cancel();
  //   listener.remove(meetingId);
  // }

  // 모임 참여하기
  // void joinMeeting(
  //     String meetingId, String hostUid, DateTime meetingTime) async {
  //   isLoading.value = true;
  //   try {
  //     await MemberRepository.create(
  //         memberUid: FirebaseReference.currentUid!,
  //         meetingId: meetingId,
  //         hostUid: hostUid);
  //     Get.back();
  //     Get.snackbar(
  //       '모임참여 성공',
  //       '모임에 참여하였습니다',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     isLoading.value = false;
  //   } catch (e) {
  //     debugPrint('모임참여 실패 ${e.toString()}');
  //     Get.snackbar(
  //       '모임참여 실패',
  //       e.toString(),
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //     );
  //     isLoading.value = false;
  //   }
  // }

  // 카테고리 필터
  void clickedFilter(MeetingCategory? category) {
    this.category.value = category?.displayName ?? '필터';
    for (var meeting in _snapshotMeetingsAndMarkers.values) {
      final visible = (category == null)
          ? true
          : meeting.meeting.category == category.displayName;
      Marker updatedMarker = meeting.marker.copyWith(visibleParam: visible);
      _snapshotMeetingsAndMarkers[meeting.meeting.id!] =
          (meeting: meeting.meeting, marker: updatedMarker);
    }
    _convertMeetings();
  }

  // Future<void> downloadHostImage(String? url) async {
  //   if (url == null) hostImage.value = const AssetImage(Assets.imageNoImage);
  //   final imageBytes = await DrawIconOfMeeting.downloadImage(url);
  //   hostImage.value = Image.memory(imageBytes).image;
  // }
}

enum IconColors {
  host(Colors.red),
  join(Colors.green),
  defalt(Colors.blue);

  final Color color;
  const IconColors(this.color);
}

class MapPageControllerUtils {
  DrawIconOfMeeting drawIconOfMeeting;
  late final Map<String, ui.Image> iconFrames;
  late final Map<String, BitmapDescriptor> loadingIcons;

  MapPageControllerUtils({required this.drawIconOfMeeting}) {
    _initializeVariables();
  }

  Future<void> _initializeVariables() async {
    // 지도에서 쓸 아이콘 생성
    final (iconFrames, loadingIcons) = await drawIconImages();
    this.iconFrames = iconFrames;
    this.loadingIcons = loadingIcons;
  }

  /// 지도에 보여줄 아이콘 이미지 미리 만들어놓기
  Future<(Map<String, ui.Image>, Map<String, BitmapDescriptor>)>
      drawIconImages() async {
    final futureIconFrames = {
      for (final color in IconColors.values)
        color.name: drawIconOfMeeting.drawIconFrame(color.color)
    };
    final iconFrames = Map.fromIterables(
        futureIconFrames.keys, await Future.wait(futureIconFrames.values));

    // 웹 이미지 가져오는동안 보여줄 아이콘
    final loadingIcons = await drawIconOfMeeting.drawLoadingIcons(iconFrames);

    return (iconFrames, loadingIcons);
  }

  Marker creatLoadingMeetingMarker(Meeting meeting) {
    // Host 여부, 참여 여부에 따라 다른색 아이콘
    final String iconColor;
    if (meeting.hostUid == FirebaseReference.currentUid) {
      // host일때
      iconColor = IconColors.host.name;
    } else if (MainPageController.instance.userMeetings
        .any((userMeeting) => userMeeting.meetingId == meeting.id)) {
      // 참여중인 모임일때
      iconColor = IconColors.join.name;
    } else {
      // 둘다 아닐때
      iconColor = IconColors.defalt.name;
    }

    final loadingIcon = loadingIcons[iconColor];

    // 우선 로딩아이콘으로 마커표시
    final markerForLoading = Marker(
      markerId: MarkerId(meeting.id!),
      position: meeting.location,
      icon: loadingIcon!,
      onTap: () => meetingInfoSheet(meeting.id!),
    );

    return markerForLoading;
  }

  Future<Marker> fetchMeetingMarker(Meeting meeting) async {
    try {
      // Host 정보 가져오기
      if (meeting.hostName == null) {
        meeting = await MeetingRepository.fetchHostNameAndImage(meeting);
      }

      // Host 여부, 참여 여부에 따라 다른색 아이콘
      final String iconColor;
      if (meeting.hostUid == FirebaseReference.currentUid) {
        // host일때
        iconColor = IconColors.host.name;
      } else if (MainPageController.instance.userMeetings
          .any((userMeeting) => userMeeting.meetingId == meeting.id)) {
        // 참여중인 모임일때
        iconColor = IconColors.join.name;
      } else {
        // 둘다 아닐때
        iconColor = IconColors.defalt.name;
      }

      // Marker 이미지를 가져온 HostImage로 교체
      final icon = await drawIconOfMeeting.drawMeetingIcon(
          meeting.hostImageUrl!, iconFrames[iconColor]!);

      // Web이미지로 마커 새로 그리기
      final marker = Marker(
        markerId: MarkerId(meeting.id!),
        position: meeting.location,
        icon: icon,
        onTap: () => meetingInfoSheet(meeting.id!),
      );
      return marker;
    } catch (e) {
      debugPrint('에러!fetchHostData: ${e.toString()}');
      rethrow;
    }
  }
}
