import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class UserProfileController extends GetxController {
  // tag is meetingId
  static UserProfileController instance({required String tag}) =>
      Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  // User
  final String uid;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Listener Ref
  final DocumentReference<UserModel> userDocRef;

  UserProfileController({required this.uid})
      : userDocRef = FirebaseService.instance.userList.doc(uid);

  @override
  void onInit() {
    super.onInit();
    listenerForUser(uid);    
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: userDocRef);
  }

  void listenerForUser(String uid) {
    debugPrint('listenerForUser: $uid');
    try {
      final listener = userDocRef.snapshots().listen((snapshot) async {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data();
        user.value = data;
        // downloadHostImage(meeting.value!.hostImageUrl);
        debugPrint('listenerForMeeting끝');
      });
      firebaseService.addListener(ref: userDocRef, listener: listener);
    } catch (e) {
      debugPrint('에러!! listenerForMeeting: $e');
    }
  }
}