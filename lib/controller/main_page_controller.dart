import 'dart:async';

import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MainPageController extends GetxController {
  static MainPageController instance = Get.find();

  // 텝인덱스
  final _tabIndex = RxInt(0);
  RxInt get tabIndex => _tabIndex;

  // UserMeeting
  final userMeetings = RxList<UserMeeting>();

  @override
  void onInit() {
    super.onInit();
    userMeetings.bindStream(_streamUserMeetings());
  }

  void changePage(int index) {
    _tabIndex.value = index;
  }

  Stream<List<UserMeeting>> _streamUserMeetings() {
    final uid = FirebaseReference.currentUid!;
    return UserMeetingRepository.listen(uid);
  }
}
