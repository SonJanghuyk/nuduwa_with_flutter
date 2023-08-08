import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/models/meeting.dart';
import 'package:nuduwa_with_flutter/models/user.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingCardController extends GetxController {
  // tag is meetingId
  static MeetingCardController instance({required String tag}) =>
      Get.find(tag: tag);

  // Meeting
  final String meetingId;
  final meeting = Rx<Meeting?>(null);
  final _snapshotMeeting = Rx<Meeting?>(null);

  final String hostUid;
  late final ({String? name, String? image}) _hostNameAndImage;

  MeetingCardController({required this.meetingId, required this.hostUid});

  @override
  void onInit() async {
    super.onInit();

    _hostNameAndImage = await fetchHostData(hostUid);
    _snapshotMeeting.bindStream(_streamMeeting());
    ever(_snapshotMeeting, convertMeeting);
  }

  void convertMeeting(Meeting? snapshotMeeting) {
    final tempMeeting = snapshotMeeting!;
    tempMeeting.hostName = _hostNameAndImage.name;
    tempMeeting.hostImageUrl = _hostNameAndImage.image;
    meeting.value = tempMeeting;
  }

  Stream<Meeting?> _streamMeeting() {
    return MeetingRepository.stream(meetingId: meetingId);
  }

  Future<({String? name, String? image})> fetchHostData(String hostUid) async {
    final host = await UserRepository.readOnlyNameAndImage(hostUid);
    return (name: host.$1, image: host.$2);
  }

  // Future<void> downloadHostImage(String? url) async {
  //   if (url == null) hostImage.value = const AssetImage(Assets.imageNoImage);
  //   final imageBytes = await DrawIconOfMeeting.downloadImage(url);
  //   hostImage.value = Image.memory(imageBytes).image;
  // }

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
