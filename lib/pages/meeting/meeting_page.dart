import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_detail_page.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_list_page.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingPage extends GetView<MeetingController> {
  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Responsive.layout(
      portrait: Obx(
        () => Stack(
          children: [
            MeetingListPage(
              onTap: controller.onTapMeetingCard,
            ),
            if (controller.isOnTap.value) meetingDetailBuilder()
          ],
        ),
      ),
      landscape: landscapeWidget(),
    );
  }

  Widget landscapeWidget() {
    return Center(
      child: Container(
          // constraints: const BoxConstraints(maxWidth: 1300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: MeetingListPage(
                onTap: controller.onTapMeetingCard,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (!controller.isOnTap.value) {
                  return const MeetingDetailNullPage();
                } else {
                  return meetingDetailBuilder();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Builder meetingDetailBuilder() {
    Get.put(MeetingDetailController(meetingId: controller.tapMeetingId), tag: controller.tapMeetingId);
    return Builder(
      key: GlobalKey(),
      builder: (_) => MeetingDetailPage(
        meetingId: controller.tapMeetingId,
        onClose: controller.onCloseMeetingDetail,
      ),
    );
  }
}

class MeetingDetailNullPage extends StatelessWidget {
  const MeetingDetailNullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldOfNuduwa(
      body: Center(
        child: Text('왼쪽에서 모임을 클릭해주세요'),
      ),
    );
  }
}
