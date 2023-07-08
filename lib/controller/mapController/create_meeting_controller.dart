import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:http/http.dart' as http;

class CreateMeetingController extends GetxController {
  final meetingManager = MeetingManager.instance;
  final title = ''.obs;
  final description = ''.obs;
  final place = ''.obs;
  var maxMemers = 0;
  var category = '';

  final LatLng location;
  String? goeHash;

  DateTime meetingTime = DateTime(0);

  final address = ''.obs;

  CreateMeetingController(this.location);

  @override
  void onInit() {
    debugPrint("CreateMeetingController");
    super.onInit();
    getLocationAddress();
  }

  void createMeeting() async {
    if (meetingManager.currentUid == null) {
      getXsnackbar('오류: 계정오류', '사용자 계정이 없습니다');
      return;
    }
    if (title.value.isEmpty || title.value.length < 2) {
      getXsnackbar('오류: 모임제목 오류', '모임제목을 2글자이상 입력해주세요');
      return;
    }
    if (description.value.isEmpty) {
      getXsnackbar('오류: 모임내용 오류', '모임내용을 입력해주세요');
      return;
    }
    if (place.value.isEmpty) {
      getXsnackbar('오류: 모임장소 오류', '모임장소를 입력해주세요');
      return;
    }
    if (maxMemers < 2) {
      getXsnackbar('오류: 모임최대인원수 오류', '모임 최대인원을 2명이상 선택해주세요');
      return;
    }
    if (category.isEmpty) {
      getXsnackbar('오류: 모임카테고리 오류', '모임카테고리를 선택해주세요');
      return;
    }
    if (meetingTime == DateTime(0)) {
      getXsnackbar('오류: 모임시간 오류', '알 수 없는 오류');
      return;
    }

    final newMeeting = Meeting(
      title: title.value,
      description: description.value,
      place: place.value,
      maxMemers: maxMemers,
      category: category,
      location: location,
      meetingTime: meetingTime,
      hostUid: meetingManager.currentUid!,
    );
    try {
      await meetingManager.createMeetingData(newMeeting);
      Get.back();
      Get.snackbar('모임생성 완료', '모임생성이 완료되었습니다', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('모임생성 오류', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${location.latitude},${location.longitude}',
      'key': 'AIzaSyD7HNss1CtBe-KstkVFyLjHwNeBr7Yj06c',
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
