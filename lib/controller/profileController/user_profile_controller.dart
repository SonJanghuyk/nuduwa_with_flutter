import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/chatting.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/screens/chatting/sub/chatting_room_page.dart';
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
  final DocumentReference<UserModel> userDocRef;// = FirebaseService.instance.userList.doc(FirebaseService.instance.currentUid!);

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
        debugPrint('listenerForUser끝');
      });
      firebaseService.addListener(ref: userDocRef, listener: listener);
    } catch (e) {
      debugPrint('에러!! listenerForUser: $e');
    }
  }

  Future<void> clickedChattingButton() async {
    final currentUid = firebaseService.currentUid;
    if (currentUid == null) return;
    final userChattingRepository = UserChattingRepository.instance;

    try {
      final userChatting = await userChattingRepository.readUserChattingData(
          uid: currentUid, otherUid: uid);
      if (userChatting != null) {
        Get.to(() => ChattingRoomPage(userChatting: userChatting));
        return;
      }

      final ref = await ChattingRepository.instance
          .createChattingData(uid: currentUid, otherUid: uid);
      await Future.wait([
        userChattingRepository.createUserChattingData(
            chattingId: ref.id, uid: currentUid, otherUid: uid),
        userChattingRepository.createUserChattingData(
            chattingId: ref.id, uid: uid, otherUid: currentUid),
      ]);

      final newUserChatting = UserChatting(
          chattingId: ref.id, otherUid: uid, lastReadTime: DateTime.now());

      Get.to(() => ChattingRoomPage(userChatting: newUserChatting));
      return;
    } catch (e) {
      debugPrint('clickedChattingButton에러: ${e.toString()}');
      rethrow;
    }
  }
}
