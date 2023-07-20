import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/main.dart';

class ChattingPage extends StatelessWidget {
  const ChattingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarOfNuduwa(title: '채팅'),
      body: Center(
        child: Container(/*
          constraints: const BoxConstraints(maxWidth: 500),
          child: Obx(() => ListView.separated(
                itemCount: service.userMeetings.length,
                itemBuilder: (context, index) => MeetingCard(
                    controller: Get.put(
                        MeetingCardController(
                            meetingId: service.userMeetings[index].meetingId),
                        tag: service.userMeetings[index].meetingId)),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 0, child: Divider()),
              )),*/
        ),
      ),
    );
  }
}