import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/main.dart';

class ChattingPage extends StatelessWidget {
  ChattingPage({super.key});

  final controller = Get.put(ChattingPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarOfNuduwa(title: '채팅'),
      body: Center(
        child: Container(
          // constraints: const BoxConstraints(maxWidth: 500),
          // child: Obx(() => ListView.separated(
          //       itemCount: controller.userChatting.length,
          //       itemBuilder: (context, index) => MeetingCard(
          //           controller: Get.put(
          //               MeetingCardController(
          //                   meetingId: service.userMeetings[index].meetingId),
          //               tag: service.userMeetings[index].meetingId)),
          //       separatorBuilder: (context, index) =>
          //           const SizedBox(height: 0, child: Divider()),
          //     )),
        ),
      ),
    );
  }
}