import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingPageController extends GetxController {
  static ChattingPageController get instance => Get.find();

  // Model Manager
  final firebaseService = FirebaseService.instance;
  late Query<UserChatting> query;

  final userChatting = <UserChatting>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenerForUserChattingList();
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: query);
  }

  void listenerForUserChattingList() {
    if (firebaseService.currentUid == null) return;

    final ref = firebaseService.userChattingList(firebaseService.currentUid!);
    query = ref.orderBy('lastReadTime');
    final listener = query.snapshots().listen((snapshot) {
      final snapshotUserChatting = snapshot.docs.map((doc) => doc.data()).toList();
      userChatting.value = snapshotUserChatting;
    });
    
    firebaseService.addListener(ref: query, listener: listener);
  }
}