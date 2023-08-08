import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_interface.dart';
import 'package:nuduwa_with_flutter/models/message.dart';
import 'package:nuduwa_with_flutter/models/user.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingRoomController extends GetxController implements ChattingController {
  // tag is meetingId
  static ChattingRoomController instance({required String tag}) =>
      Get.find(tag: tag);
  
  final String userChattingId;
  final String chattingId;
  final String otherUid;  

  final otherUser = Rx<User?>(null);

  late Query messageQuery;

  // chatting
  @override
  final messages = <Message>[].obs;
  @override
  final textController = TextEditingController();
  @override
  final scrollController = ScrollController();
  @override
  var isNotLast = false.obs;

  ChattingRoomController({required this.userChattingId, required this.chattingId, required this.otherUid});

  @override
  void onInit() async {
    super.onInit();
    streamForMessages();
    updateLastReadTime();
    otherUser.value = await fetchOtherUserData(otherUid: otherUid);
  }

  @override
  void onReady() {
    super.onReady();
    messages.bindStream(streamForMessages());
    ever(messages, (_) => updateLastReadTime());
  }

  @override
  void onClose() {
    super.onClose();
    textController.dispose();
  }

  
  @override
  Stream<List<Message>> streamForMessages() {
    try {
      final ref = FirebaseReference.chattingMessageList(chattingId);
      final query = ref.orderBy('sendTime', descending: true);
      final stream = query.streamAllDocuments<Message>();
      return stream;
    } catch (e) {
      debugPrint('오류!! listenerForMessages: ${e.toString()}');
      rethrow;
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
      await ChattingMessageRepository.create(chattingId: chattingId, uid: FirebaseReference.currentUid!, text: text);
      
    } catch (e) {
      debugPrint('오류!! sendMessage: ${e.toString()}');
    }
  }

  void updateLastReadTime() {
    debugPrint('userChattingId엥:$userChattingId');
    UserChattingRepository.updateLastReadTime(uid: FirebaseReference.currentUid!, userChattingId: userChattingId);
  }

  Future<User?> fetchOtherUserData({required String otherUid}) async {
    debugPrint('fetchOtherUserData');
    try{
      final user = await UserRepository.read(otherUid);
      debugPrint(user?.name);
      return user;

    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  void scrollLast() {
    scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );    
  }

  void showUserProfile(String uid) {
    Get.toNamed('/userProfile', arguments: uid);
  }

  void clickedOut() {
    String previousRoute = Get.previousRoute;
    String currentRoute = Get.currentRoute;
    
    debugPrint('Previous Route: $previousRoute');
    debugPrint('Current Route: $currentRoute');
  }
}
