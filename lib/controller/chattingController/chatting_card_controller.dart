import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/message.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/pages/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class ChattingCardController extends GetxController {
  // tag is chattingId
  static ChattingCardController instance({required String tag}) =>
      Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  // Listener Ref
  final CollectionReference<Message> messageColRef;

  // Chatting
  final UserChatting userChatting;
  final message = RxList<Message>();
  final otherUser = Rx<UserModel?>(null);

  ChattingCardController({required this.userChatting})
      : messageColRef = FirebaseService.instance.chattingMessageList(userChatting.chattingId);

  @override
  void onInit() async {
    super.onInit();
    final listener = listenerForMessage(messageColRef);
    firebaseService.addListener(ref: messageColRef, listener: listener);
    otherUser.value = await fetchOtherUser(userChatting.otherUid);
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: messageColRef);
  }

  StreamSubscription listenerForMessage(CollectionReference<Message> messageColRef) {
    debugPrint('listenerForMessage');
    try {
      final listener = messageColRef.snapshots().listen((querySnapshot) {
        var snapshotMessage = <Message>[];
        snapshotMessage = querySnapshot.docs.map((doc) => doc.data()).toList();
        message.value = snapshotMessage;

        debugPrint('listenerForMessage끝');
      });
      return listener;
    } catch (e) {
      debugPrint('에러!! listenerForMeeting: $e');
      rethrow;
    }
  }

  Future<UserModel?> fetchOtherUser(String uid) async {
    try{
      final user = await UserRepository.instance.readUserData(uid);
      return user;
    }catch(e){
      debugPrint('에러!! fetchOtherUser: $e');
      rethrow;
    }
  }

  void onTapMeetingCard() {
    // debugPrint('라우팅:${Get.nestedKey(1)!.currentState!}');
    // final move = Responsive.action(
    //   mobile: () =>
    //       Get.toNamed('/meeting/detail', arguments: meeting.value!.id, id: 1),
    //   tablet: () =>
    //       Get.toNamed('/meeting/detail', arguments: meeting.value!.id, id: 1),
    //   desktop: () =>
    //       Get.offNamed('/meeting/detail', arguments: meeting.value!.id, id: 1),
    // );
    // move(); 
  }
}
