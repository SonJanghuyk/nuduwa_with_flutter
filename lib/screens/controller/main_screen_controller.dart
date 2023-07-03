import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreenController extends GetxController {
  String? _permissionMessage;
  String? get permissionMessage => _permissionMessage;

  late LatLng _currentLatLng;
  LatLng get currentLatLng => _currentLatLng;

  late List<Widget> _screens;
  List<Widget> get screens => _screens;

  final Rx<User?> _currentUser = Rx<User?>(null);
  Rx<User?> get currentUser => _currentUser;

  final RxInt _tabIndex = 0.obs;
  RxInt get tabIndex => _tabIndex;

  // 위치 권한 체크
  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스 활성화 여부 확인
    if (!isLocationEnabled) {
      // 위치 서비스 활성화 안됨
      return '위치 서비스를 활성화해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    //위치 권한 확인
    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 거절됨
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      // 위치 권한 거절됨 (앱에서 재요청 불가)
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    final currentPosition = await Geolocator.getCurrentPosition();

    _currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

    return '위치 권한이 허가 되었습니다.';
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser.value = null;
    } catch (e) {
      // 로그아웃 실패 처리
    }
  }

  void changeIndex(int index) {
    _tabIndex(index);
  }

  @override
  void onInit() {
    super.onInit();

    // 초기화 로직 추가
    checkPermission().then((permissionStatus) {
      _permissionMessage = permissionStatus;
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser.value = user;
    });
  }
}
