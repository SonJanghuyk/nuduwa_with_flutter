import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_interface.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/profileController/user_profile_controller.dart';
import 'package:nuduwa_with_flutter/screens/chatting/chatting_page.dart';
import 'package:nuduwa_with_flutter/screens/map/map_page.dart';
import 'package:nuduwa_with_flutter/screens/meeting/meeting_page.dart';
import 'package:nuduwa_with_flutter/screens/profile/my_profile_page.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/service/data_service.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

import '../model/user_meeting.dart';

class HomePageController extends GetxController {
  static HomePageController instance = Get.find();

  // TabPageList
  final pages = <String>['/map', '/meeting', '/chatting', '/profile'];

  // 위치 권한 메시지
  final permissionMessage = RxString('');

  // 현재 위치
  final currentLatLng = Rx<LatLng?>(null);

  // 텝인덱스
  final tabIndex = RxInt(0);
  final overlayPage = Rx<Widget?>(null);

  // UserMeeting
  final userMeetings = <UserMeeting>[].obs;
  final leavedMeeting = <UserMeeting?>[].obs;

  final firebaseService = FirebaseService.instance;

  late final String mapStyle;

  @override
  void onInit() async {
    super.onInit();

    // 위치 권한 체크
    final(message, latLng) = await _checkPermission();
    permissionMessage.value = message;
    currentLatLng.value = latLng;

    mapStyle = await  rootBundle.loadString('assets/map_style.txt');
  }

  @override
  void onReady() {
    super.onReady();

    listenerForUserMeetings(AuthService.instance.isLogin.value);
    ever(AuthService.instance.isLogin, listenerForUserMeetings);
  }

  // 위치 권한 체크
  Future<(String, LatLng?)> _checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스 활성화 여부 확인
    if (!isLocationEnabled) {
      // 위치 서비스 활성화 안됨
      return ('위치 서비스를 활성화해주세요.', null);
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    //위치 권한 확인
    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 거절됨
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return ('위치 권한을 허가해주세요.', null);
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      // 위치 권한 거절됨 (앱에서 재요청 불가)
      return ('앱의 위치 권한을 설정에서 허가해주세요.', null);
    }

    final currentPosition = await Geolocator.getCurrentPosition();

    return (
      '위치 권한이 허가 되었습니다.',
      LatLng(currentPosition.latitude, currentPosition.longitude)
    );
  }

  void changePage(int index) {
    tabIndex.value = index;
    Get.toNamed(pages[index], id: 1);
    overlayPage.value = null;
  }

  Route onGenerateRoute(RouteSettings settings) {
    debugPrint('라우트: ${settings.name}');
    late Route pageRoute;
    switch (settings.name) {
      case '/map' || '/':
        pageRoute = GetPageRoute(
          settings: settings,
          page: () => MapPage(),
          binding: BindingsBuilder(() {
            Get.put(MapPageController(location: currentLatLng.value, mapStyle: mapStyle));
          }),
          transition: Transition.noTransition,
        );
        break;

      case '/meeting':
        pageRoute = GetPageRoute(
          settings: settings,
          page: () => MeetingPage(),
          transition: Transition.noTransition,
        );
        break;

      case '/chatting':
        pageRoute = GetPageRoute(
          settings: settings,
          page: () => ChattingPage(),
          binding: BindingsBuilder(() {
            Get.put(ChattingController());
          }),
          transition: Transition.noTransition,
        );
        break;

      case '/profile':
        pageRoute = GetPageRoute(
          settings: settings,
          page: () => MyProfilePage(),
          binding: BindingsBuilder(() {
            Get.put(UserProfileController());
          }),
          transition: Transition.noTransition,
        );
        break;
    }
    return pageRoute;
  }

  listenerForUserMeetings(bool isLogin) {
    debugPrint('UserMeeting 리스너1');
    if (!isLogin) return;
    firebaseService
        .userMeetingList(firebaseService.currentUid!)
        .snapshots()
        .listen((snapshot) {
      final snapshotUserMeeings =
          snapshot.docs.map((doc) => doc.data()).toList();
      userMeetings.value = snapshotUserMeeings;
      leavedMeeting.value = snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.removed)
          .map((change) => change.doc.data())
          .toList();
    });
  }
}
