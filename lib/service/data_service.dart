import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../model/user_meeting.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class DataService extends GetxService {
  static DataService get instance => Get.find();

  final firebaseService = FirebaseService.instance;
  // UserMeeting
  final userMeetings = <UserMeeting>[].obs;
  final leavedMeeting = <UserMeeting?>[].obs;

  DataService() {
    listenerForUserMeetings(AuthService.instance.isLogin.value);
    ever(AuthService.instance.isLogin, listenerForUserMeetings);
  }

  // UserMeeting 리스너
  listenerForUserMeetings(bool isLogin) {
    debugPrint('UserMeeting 리스너1');
    if (!isLogin) return;
    firebaseService.userMeetingList(firebaseService.currentUid!)
        .snapshots()
        .listen((snapshot) {
      final snapshotUserMeeings = snapshot.docs.map((doc) => doc.data()).toList();
      userMeetings.value = snapshotUserMeeings;
      leavedMeeting.value = snapshot.docChanges.where((change) => change.type == DocumentChangeType.removed).map((change) => change.doc.data()).toList();
    });
  }
}