import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPageController extends GetxController {
  // 위치 권한 메시지
  final permissionMessage = RxString('');

  // 현재 위치
  final currentLatLng = Rx<LatLng?>(null);

  // 텝인덱스
  final tabIndex = RxInt(0);

  @override
  void onInit() {
    super.onInit();

    // 위치 권한 체크
    _checkPermission().then((result) {
      permissionMessage.value = result.$1;
      currentLatLng.value = result.$2;
    });
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

    return ('위치 권한이 허가 되었습니다.', LatLng(currentPosition.latitude, currentPosition.longitude));
  }

  void changeIndex(int index) {
    tabIndex(index);
  }

}
