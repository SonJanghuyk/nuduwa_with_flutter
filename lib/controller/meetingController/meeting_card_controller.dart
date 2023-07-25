import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/pages/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingCardController extends GetxController {
  // tag is meetingId
  static MeetingCardController instance({required String tag}) =>
      Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  // Listener Ref
  final DocumentReference<Meeting> meetingDocRef;

  // Meeting
  final String meetingId;
  final meeting = Rx<Meeting?>(null);
  final hostImage = Rx<ImageProvider?>(null);

  MeetingCardController({required this.meetingId})
      : meetingDocRef = FirebaseService.instance.meetingList.doc(meetingId);

  @override
  void onInit() {
    super.onInit();
    listenerForMeeting(meetingId);
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: meetingDocRef);
  }

  void listenerForMeeting(String meetingId) {
    debugPrint('listenerForMeeting: $meetingId');
    try {
      final listener = meetingDocRef.snapshots().listen((snapshot) async {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data();
        if (data?.publishedTime is! DateTime) {
          data!.publishedTime = meeting.value?.publishedTime ?? DateTime.now();
        }
        meeting.value = data;
        final temp =
            await MeetingRepository.instance.fetchHostData(meeting.value!);
        meeting.value = Meeting.clone(temp);
        downloadHostImage(meeting.value!.hostImageUrl);
        debugPrint('listenerForMeeting끝');
      });
      firebaseService.addListener(ref: meetingDocRef, listener: listener);
    } catch (e) {
      debugPrint('에러!! listenerForMeeting: $e');
    }
  }

  Future<void> downloadHostImage(String? url) async {
    if (url == null) hostImage.value = const AssetImage(Assets.imageNoImage);
    final imageBytes = await DrawIconOfMeeting.downloadImage(url);
    hostImage.value = Image.memory(imageBytes).image;
  }

  void onTapMeetingCard() {
    debugPrint('라우팅:${Get.nestedKey(1)!.currentState!}');
    debugPrint('무브0');
    
    debugPrint('무브00');
    // Get.toNamed('/meeting/empty', id: 1);
    debugPrint('무브1');
    final move = Responsive.action(
      portrait: () =>
          Get.toNamed('/meeting/detail', arguments: meeting.value!.id, id: 1),
      landscape: () =>
          Get.offNamed('/meeting/detail', arguments: meeting.value!.id, id: 1),
    );
    debugPrint('무브2');
    move();
    debugPrint('무브3');
    // Get.offNamedUntil('/meeting/detail', ModalRoute.withName('/meeting/detail'), id: 1, arguments: meeting.value!.id,);
    // Get.removeRoute(ModalRoute.withName('/meeting/detail') as Route<dynamic>, id: 1);
  }
}
