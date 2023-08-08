import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_interface.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
import 'package:nuduwa_with_flutter/models/member.dart';
import 'package:nuduwa_with_flutter/models/message.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingChatController extends GetxController
    implements ChattingController {
  // tag is meetingId
  static MeetingChatController instance({required String tag}) =>
      Get.find(tag: tag);


  final String meetingId;
  final String title;
  final RxMap<String, Member> members;
  // chatting
  @override
  final messages = RxList<Message>();
  @override
  final textController = TextEditingController();
  @override
  final scrollController = ScrollController();
  @override
  var isNotLast = false.obs;

  MeetingChatController({required this.meetingId})
      : title = MeetingDetailController.instance(tag: meetingId)
            .meeting
            .value!
            .title,
        members = MeetingDetailController.instance(tag: meetingId).members;

  @override
  void onInit() {
    super.onInit();
    messages.bindStream(streamForMessages());
    scrollListener();
  }

  @override
  void onClose() {
    super.onClose();
    textController.dispose();
    scrollController.dispose();
  }

  @override
  Stream<List<Message>> streamForMessages() {
    try {
      final ref = FirebaseReference.meetingMessageList(meetingId);
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
      // FocusScope.of(Get.context!).unfocus();
      await MeetingMessageRepository.create(meetingId: meetingId, uid: FirebaseReference.currentUid!, text: text);
      debugPrint(messages.length.toString());
      debugPrint('sendMessage 끝');
    } catch (e) {
      debugPrint('오류!! sendMessage: ${e.toString()}');
    }
  }

  @override
  void scrollLast() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollListener() {
    scrollController.addListener(() {
      if (scrollController.offset !=
          scrollController.position.minScrollExtent) {
        isNotLast.value = true;
      } else {
        isNotLast.value = false;
      }
    });
  }

  void showUserProfile(String uid) {
    Get.toNamed(RoutePages.userProfile(uid: uid));
  }
}
