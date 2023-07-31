import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_interface.dart';
import 'package:nuduwa_with_flutter/model/message.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/pages/profile/user_profile_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingRoomController extends GetxController implements ChattingController {
  // tag is meetingId
  static ChattingRoomController instance({required String tag}) =>
      Get.find(tag: tag);
  
  final UserChatting userChatting;

  final otherUser = Rx<UserModel?>(null);

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

  ChattingRoomController({required this.userChatting});

  @override
  void onInit() async {
    super.onInit();
    listenerForMessages();
    updateLastReadTime();
    otherUser.value = await fetchOtherUserData(otherUid: userChatting.otherUid);
  }

  @override
  void onReady() {
    super.onReady();
    messages.bindStream(listenerForMessages());
    ever(messages, (_) => updateLastReadTime());
  }

  @override
  void onClose() {
    super.onClose();
    // firebaseService.cancelListener(ref: messageQuery);
    textController.dispose();
  }

  
  @override
  Stream<List<Message>> listenerForMessages() {
    try {
      // debugPrint('listenerForMessages');
      // final ref = FirebaseRoute.chattingMessageList(userChatting.chattingId);
      // messageQuery = ref.orderBy('sendTime', descending: true);

      // final listener = messageQuery.snapshots().listen((snapshot) {
      //   final snapshotMessages = snapshot.docs.map((doc) => doc.data());
      //   messages.value = List.from(snapshotMessages);
      //   debugPrint('listenerForMessages ${messages.length}');
      // });
      final ref = FirebaseReference.chattingMessageList(userChatting.chattingId);
      final query = ref.orderBy('sendTime', descending: true);
      final stream = query.listenAllDocuments<Message>();
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
      await ChattingMessageRepository.create(chattingId: userChatting.chattingId, uid: FirebaseReference.currentUid!, text: text);

      debugPrint(messages.length.toString());
      debugPrint('sendMessage 끝');
      
    } catch (e) {
      debugPrint('오류!! sendMessage: ${e.toString()}');
    }
  }

  void updateLastReadTime() {
    UserChattingRepository.updateLastReadTime(uid: FirebaseReference.currentUid!, userChattingId: userChatting.id!);
  }

  Future<UserModel?> fetchOtherUserData({required String otherUid}) async {
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
