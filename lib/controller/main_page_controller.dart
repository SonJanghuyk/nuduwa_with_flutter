import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/models/user_meeting.dart';

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid==null) throw 'no Login';
    return UserMeetingRepository.listen(uid);
  }
}
