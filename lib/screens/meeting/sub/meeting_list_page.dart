import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/home_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_list_controller.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_card.dart';
import 'package:nuduwa_with_flutter/screens/scaffold_of_nuduwa.dart';

class MeetingListPage extends StatelessWidget {
  MeetingListPage({super.key});  

  final controller = HomePageController.instance;

  @override
  Widget build(BuildContext context) {
    return ScaffoldOfNuduwa(
      appBar: const AppbarOfNuduwa(title: '내 모임'),
      body: ListView.separated(
        itemCount: controller.userMeetings.length,
        itemBuilder: (context, index) => MeetingCard(
            controller: Get.put(
                MeetingCardController(
                    meetingId: controller.userMeetings[index].meetingId),
                tag: controller.userMeetings[index].meetingId)),
        separatorBuilder: (context, index) =>
            const SizedBox(height: 0, child: Divider()),
      ),
    );
  }
}
