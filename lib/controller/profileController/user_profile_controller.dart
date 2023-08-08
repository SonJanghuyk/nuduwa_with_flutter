import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/models/chat_room.dart';
import 'package:nuduwa_with_flutter/models/user.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';

class UserProfileController extends GetxController {
  // tag is meetingId
  static UserProfileController instance({required String tag}) =>
      Get.find(tag: tag);

  // User
  final String uid;
  final Rx<User?> user = Rx<User?>(null);

  UserProfileController({required this.uid});

  @override
  void onInit() {
    super.onInit();
    user.bindStream(listenerForUser(uid));
  }

  Stream<User?> listenerForUser(String uid) {
    return UserRepository.stream(uid);
  }

  Future<void> clickedChattingButton() async {
    final currentUid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    try {
      final userChatting = await UserChattingRepository.read(
          uid: currentUid, otherUid: uid);
      if (userChatting != null) {
        Get.toNamed(RoutePages.chattingRoom(userChatting: userChatting));
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
      Get.toNamed(RoutePages.chattingRoom(userChatting: newUserChatting));
      return;
    } catch (e) {
      debugPrint('clickedChattingButton에러: ${e.toString()}');
      rethrow;
    }
  }
}
