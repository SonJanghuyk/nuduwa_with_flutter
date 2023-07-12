import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MeetingCardController extends GetxController {
  static MeetingCardController instance(String tag) => Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  final meeting = Rx<Meeting?>(null);
  final UserMeeting userMeeting;

  final hostImage = Rx<ImageProvider?>(null);

  MeetingCardController({required this.userMeeting, ImageProvider? hostImage}) {
    listenerForMeeting(userMeeting.meetingId);
  }

  void listenerForMeeting(String meetingId) {
    debugPrint('listenerForMeeting: $meetingId');
    final ref = firebaseService.meetingList.doc(meetingId);
    try {
      ref.snapshots().listen((snapshot) async {
        debugPrint('listenerForMeeting - meeting: ${snapshot.data()}');
        if (!snapshot.exists || snapshot.data()==null) return;
        meeting.value = snapshot.data();
        final temp = await firebaseService.fetchHostData(meeting.value!);
        meeting.value = Meeting.clone(temp!);
        downloadHostImage(meeting.value!.hostImageUrl);
        debugPrint('listenerForMeeting끝');
      });
    } catch (e) {
      debugPrint('에러!! listenerForMeeting: $e');
    }
  }

  Future<void> downloadHostImage(String? url) async {
    if (url == null) hostImage.value = const AssetImage(Assets.imageNoImage);
    final imageBytes = await DrawIconOfMeeting.downloadImage(url);
    hostImage.value = Image.memory(imageBytes).image;
  }
}
