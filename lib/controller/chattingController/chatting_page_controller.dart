import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingPageController extends GetxController {
  static ChattingPageController get instance => Get.find();

  // Model Manager
  late Query<UserChatting> query;

  final userChatting = <UserChatting>[].obs;

  final isOnTap = RxBool(false);
  UserChatting? tapUserChatting;

  @override
  void onInit() {
    super.onInit();
    listenerForUserChattingList();
  }

  void listenerForUserChattingList() {
    if (FirebaseReference.currentUid == null) return;

    final ref = FirebaseReference.userChattingList(FirebaseReference.currentUid!);
    query = ref.orderBy('lastReadTime');
    final listener = query.snapshots().listen((snapshot) {
      final snapshotUserChatting = snapshot.docs.map((doc) => doc.data()).toList();
      userChatting.value = snapshotUserChatting;
    });
    
    // firebaseService.addListener(ref: query, listener: listener);
  }



  void onTapChattingCard(UserChatting userChatting){
    if (tapUserChatting==userChatting) return;
    isOnTap.value = false;
    tapUserChatting = userChatting;
    isOnTap.value = true;
  }

  void onCloseChattingRoom() {
    isOnTap.value = false;
  }
}
