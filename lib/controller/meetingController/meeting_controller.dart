import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingController extends GetxController {
  static MeetingController get instance => Get.find();

  final isOnTap = RxBool(false);
  String tapMeetingId = '';

  void onTapMeetingCard(String meetingId){
    isOnTap.value = false;
    tapMeetingId = meetingId;
    isOnTap.value = true;
  }

  void onCloseMeetingDetail() {
    isOnTap.value = false;
  }
}
