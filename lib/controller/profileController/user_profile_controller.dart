import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/chatting.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class UserProfileController extends GetxController {
  // tag is meetingId
  static UserProfileController instance({required String tag}) =>
      Get.find(tag: tag);

  // User
  final String uid;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  UserProfileController({required this.uid});

  @override
  void onInit() {
    super.onInit();
    user.bindStream(listenerForUser(uid));
  }

  Stream<UserModel?> listenerForUser(String uid) {
    return UserRepository.listen(uid);
  }

  Future<void> clickedChattingButton() async {
    final currentUid = FirebaseReference.currentUid;
    if (currentUid == null) return;

    try {
      final userChatting = await UserChattingRepository.read(
          uid: currentUid, otherUid: uid);
      if (userChatting != null) {
        // Get.to(() => ChattingRoomPage(userChatting: userChatting));
        return;
      }

      final ref = await ChattingRepository
          .create(uid: currentUid, otherUid: uid);
      await Future.wait([
        UserChattingRepository.create(
            chattingId: ref.id, uid: currentUid, otherUid: uid),
        UserChattingRepository.create(
            chattingId: ref.id, uid: uid, otherUid: currentUid),
      ]);

      final newUserChatting = UserChatting(
          chattingId: ref.id, otherUid: uid, lastReadTime: DateTime.now());

      // Get.to(() => ChattingRoomPage(userChatting: newUserChatting));
      return;
    } catch (e) {
      debugPrint('clickedChattingButton에러: ${e.toString()}');
      rethrow;
    }
  }
}
