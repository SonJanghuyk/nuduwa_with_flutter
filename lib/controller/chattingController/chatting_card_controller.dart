import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/models/message.dart';
import 'package:nuduwa_with_flutter/models/user.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingCardController extends GetxController {
  // tag is chattingId
  static ChattingCardController instance({required String tag}) =>
      Get.find(tag: tag);

  // Listener Ref
  final CollectionReference<Message> messageColRef;

  // Chatting
  final UserChatting userChatting;
  final messages = RxList<Message>();
  final otherUser = Rx<User?>(null);
  final unreadCount = RxInt(0);

  ChattingCardController({required this.userChatting})
      : messageColRef = FirebaseReference.chattingMessageList(userChatting.chattingId);

  @override
  void onInit() async {
    super.onInit();
    final listener = listenerForMessage(messageColRef);
    // firebaseService.addListener(ref: messageColRef, listener: listener);
    otherUser.value = await fetchOtherUser(userChatting.otherUid);
  }

  @override
  void onReady() async {
    super.onReady();
    unreadCount.value = await countUnread(messages, userChatting.lastReadTime);
  }


  StreamSubscription listenerForMessage(CollectionReference<Message> messageColRef) {
    debugPrint('listenerForMessage');
    try {
      final listener = messageColRef.snapshots().listen((querySnapshot) {
        var snapshotMessage = <Message>[];
        snapshotMessage = querySnapshot.docs.map((doc) => doc.data()).toList();
        messages.value = snapshotMessage;

        debugPrint('listenerForMessage끝');
      });
      return listener;
    } catch (e) {
      debugPrint('에러!! listenerForMeeting: $e');
      rethrow;
    }
  }

  Future<User?> fetchOtherUser(String uid) async {
    try{
      final user = await UserRepository.read(uid);
      return user;
    }catch(e){
      debugPrint('에러!! fetchOtherUser: $e');
      rethrow;
    }
  }

  Future<int> countUnread(List<Message> messages, DateTime lastReadTime) async {
    final count = messages.indexWhere((message) => message.sendTime.isAfter(lastReadTime));
    if (count == -1) return 0;
    return count;
  }

}
