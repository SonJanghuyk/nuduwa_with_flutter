import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_card.dart';

class MeetingListPage extends StatelessWidget {
  const MeetingListPage({super.key, required this.onTap});

  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final userMeetings = MainPageController.instance.userMeetings;
    return ScaffoldOfNuduwa(
      appBar: const AppbarOfNuduwa(title: '내 모임'),
      body: Obx(
        () => ListView.separated(
          itemCount: userMeetings.length,
          itemBuilder: (context, index) {
            final meetingId = userMeetings[index].meetingId;
            final hostUid = userMeetings[index].hostUid;
            Get.lazyPut(() => MeetingCardController(meetingId: meetingId, hostUid: hostUid),
                tag: meetingId);
            return MeetingCard(
              meetingId: userMeetings[index].meetingId,
              onTap: () => onTap(userMeetings[index].meetingId),
            );
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: 0, child: Divider()),
        ),
      ),
    );
  }
}
