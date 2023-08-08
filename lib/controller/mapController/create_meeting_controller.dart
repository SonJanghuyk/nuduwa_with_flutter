import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/models/meeting.dart';
import 'package:http/http.dart' as http;
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class CreateMeetingController extends GetxController {
  final title = ''.obs;
  final description = ''.obs;
  final place = ''.obs;
  var maxMemers = 0;
  var category = '';

  LatLng location;
  String? goeHash;

  DateTime meetingTime = DateTime(0);

  final address = ''.obs;

  CreateMeetingController({required this.location});

  @override
  void onInit() {
    super.onInit();
    getLocationAddress();
  }

  void createMeeting() async {
    if (FirebaseReference.currentUid == null) {
      SnackBarOfNuduwa.error('오류: 계정오류', '사용자 계정이 없습니다');
      return;
    }
    if (title.value.isEmpty || title.value.length < 2) {
      SnackBarOfNuduwa.error('오류: 모임제목 오류', '모임제목을 2글자이상 입력해주세요');
      return;
    }
    if (description.value.isEmpty) {
      SnackBarOfNuduwa.error('오류: 모임내용 오류', '모임내용을 입력해주세요');
      return;
    }
    if (place.value.isEmpty) {
      SnackBarOfNuduwa.error('오류: 모임장소 오류', '모임장소를 입력해주세요');
      return;
    }
    if (maxMemers < 2) {
      SnackBarOfNuduwa.error('오류: 모임최대인원수 오류', '모임 최대인원을 2명이상 선택해주세요');
      return;
    }
    if (category.isEmpty) {
      SnackBarOfNuduwa.error('오류: 모임카테고리 오류', '모임카테고리를 선택해주세요');
      return;
    }
    if (meetingTime == DateTime(0)) {
      SnackBarOfNuduwa.error('오류: 모임시간 오류', '알 수 없는 오류');
      return;
    }

    final newMeeting = Meeting(
      title: title.value,
      description: description.value,
      place: place.value,
      maxMembers: maxMemers,
      category: category,
      location: location,
      meetingTime: meetingTime,
      hostUid: FirebaseReference.currentUid!,
    );
    try {
      await MeetingRepository.create(meeting: newMeeting, uid: FirebaseReference.currentUid!);
      Get.back();
      SnackBarOfNuduwa.accent('모임생성 완료', '모임생성이 완료되었습니다');
    } catch (e) {
      SnackBarOfNuduwa.warning('모임생성 오류', e.toString());
    }
  }

  void getXsnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void getLocationAddress() async {
    if (address.value != '') return;
    debugPrint('주소가져오기');
    final String? key = dotenv.env['GOOGLE_MAP_API_KEY'];
    if (key == null) return;
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${location.latitude},${location.longitude}',
      'key': key,
      'language': 'ko',
    });
    try {
      final response = await http.get(uri);
      address.value =
          jsonDecode(response.body)['results'][0]['formatted_address'];
    } catch (e) {
      debugPrint('오류!!getLocationAddress: ${e.toString()}');
    }
  }
}
