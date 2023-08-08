import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_widgets.dart';

class PermissionService extends GetxService {
  static PermissionService instance = Get.find();

  // 현재 위치
  final _currentLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> get currentLatLng => _currentLatLng;

  @override
  void onInit() async {
    super.onInit();

    // 위치 권한 체크
    final latLng = await checkLocationPermission();
    _currentLatLng.value = latLng ?? const LatLng(37.334722, -122.008889);

    // 앱 실행시 인터넷 연결 확인
    await _checkNetworkConnect();

    // 실시간 인터넷 연결 확인
    _listenConnectNetwork();
  }

  Future<void> _checkNetworkConnect() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      SnackBarOfNuduwa.error('네트워크 오류', '인터넷 연결 상태를 확인하세요');
    }
  }

  void _listenConnectNetwork() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        SnackBarOfNuduwa.error('네트워크 오류', '인터넷 연결 상태를 확인하세요');
      }
    });
  }

  // 위치 권한 체크
  Future<LatLng?> checkLocationPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스 활성화 여부 확인
    if (!isLocationEnabled) {
      // 위치 서비스 활성화 안됨
      debugPrint('위치 서비스를 활성화해주세요');
      SnackBarOfNuduwa.error('위치 권한 오류', '위치 서비스를 활성화해주세요');
      return null;
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    //위치 권한 확인
    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 거절 상태
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        debugPrint('위치 권한을 허가해주세요.');
        SnackBarOfNuduwa.error('위치 권한 오류', '현재 위치를 가져오려면 위치 권한이 필요합니다');
        return null;
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      // 위치 권한 거절됨 (앱에서 재요청 불가)
      debugPrint('앱의 위치 권한을 설정에서 허가해주세요');
      SnackBarOfNuduwa.error(
          '위치 권한 오류', '위치 권한을 더 이상 요청할 수 없습니다. 설정에서 앱의 위치 권한을 허가해주세요');
      return null;
    }

    final currentPosition = await Geolocator.getCurrentPosition();
    final currentLatLng =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    debugPrint('위치 권한이 허가되었습니다');
    return currentLatLng;
  }
}
