import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chatting_interface.dart';
import 'package:nuduwa_with_flutter/model/message.dart';
import 'package:nuduwa_with_flutter/screens/profile/user_profile_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingChatController extends GetxController implements ChattingController {
  // tag is meetingId
  static MeetingChatController instance({required String tag}) =>
      Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;
  
  final String meetingId;

  // Listener Ref
  final CollectionReference<Message> messageColRef;

  // chatting
  @override
  final messages = <Message>[].obs;
  @override
  final textController = TextEditingController();

  MeetingChatController({required this.meetingId})
      : messageColRef = FirebaseService.instance.messageList(meetingId);

  @override
  void onInit() {
    super.onInit();
    listenerForMessages();
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: messageColRef);
    textController.dispose();
  }

  void listenerForMessages() {
    try {
      debugPrint('listenerForMessages');
      final listener =
          messageColRef.orderBy('sendTime', descending: true).snapshots().listen((snapshot) {
        final snapshotMessages = snapshot.docs.map((doc) => doc.data());
        messages.value = List.from(snapshotMessages);
        debugPrint('listenerForMessages ${messages.length}');
      });
      firebaseService.addListener(ref: messageColRef, listener: listener);
    } catch (e) {
      debugPrint('오류!! listenerForMessages: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessage() async {
    debugPrint('sendMessage');
    final text = textController.text;
    if (text == '') return;
    try {
      textController.clear();
      FocusScope.of(Get.context!).unfocus();
      await firebaseService.createMessageData(
          meetingId, firebaseService.currentUid!, text);
      debugPrint(messages.length.toString());
      debugPrint('sendMessage 끝');
      
    } catch (e) {
      debugPrint('오류!! sendMessage: ${e.toString()}');
    }
  }

  void showUserProfile(String uid) {
    Get.to(() => UserProfilePage(uid: uid));
  }
}
