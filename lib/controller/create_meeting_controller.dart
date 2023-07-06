import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:http/http.dart' as http;

class CreateMeetingController extends GetxController {
  final title = ''.obs;
  final description = ''.obs;
  final place = ''.obs;
  var maxMemers = 0;
  var category = '';

  var location = LatLng(0, 0);
  String? goeHash;

  DateTime meetingTime = DateTime(0);

  final address = ''.obs;

  String? get currentUID => FirebaseAuth.instance.currentUser?.uid;

  void setLocation(LatLng location) {
    this.location = location;
    getLocationAddress();
  }

  void createMeeting() {
    if (currentUID == null) {
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
    if (maxMemers == 0) {
      getXsnackbar('오류: 모임최대인원수 오류', '알 수 없는 오류');
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
      hostUID: currentUID!,
    );
    final ref = FirebaseFirestore.instance.collection('meeting').withConverter(
          fromFirestore: Meeting.fromFirestore,
          toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
        );
    try {
      ref.add(newMeeting).then((value) {
        Get.snackbar('모임생성 완료', '모임생성이 완료되었습니다');
      });
      Get.back();
    } catch (e) {
      Get.snackbar('모임생성 오류', e.toString());
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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${location.latitude},${location.longitude}',
      'key': 'AIzaSyD7HNss1CtBe-KstkVFyLjHwNeBr7Yj06c',
      'language': 'ko',
    });
    final response = await http.get(uri);

    address.value = jsonDecode(response.body)['results'][0]['formatted_address'];
  }
}