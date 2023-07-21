import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/home_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/main.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_card.dart';

class MeetingPage extends GetView<HomePageController> {

  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppbarOfNuduwa(title: '내 모임'),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Obx(() => ListView.separated(
                itemCount: controller.userMeetings.length,
                itemBuilder: (context, index) => MeetingCard(
                    controller: Get.put(
                        MeetingCardController(
                            meetingId: controller.userMeetings[index].meetingId),
                        tag: controller.userMeetings[index].meetingId)),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 0, child: Divider()),
              )),
        ),
      ),
    );
  }
}
