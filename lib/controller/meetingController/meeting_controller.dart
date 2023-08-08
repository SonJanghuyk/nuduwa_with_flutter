import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/pages/meeting/meeting_page.dart';

class MeetingController extends GetxController {
//   static MeetingController get instance => Get.find();

  String? tapMeetingId;

  void onTapMeetingCardAtPortrait(String meetingId) {
    if (tapMeetingId == meetingId) return;
    tapMeetingId = meetingId;
    Get.toNamed(MeetingRoutePages.meetingDetail,
        arguments: meetingId, id: MeetingRoutePages.key);
  }

  void onTapMeetingCardAtlandscape(String meetingId) {
    if (tapMeetingId == null) {
      Get.to(() => const MeetingResponsivePage(onTapCardPortrait: null), id: MeetingRoutePages.key);
    }
    if (tapMeetingId == meetingId) return;
    tapMeetingId = meetingId;
    Get.offNamed(MeetingRoutePages.meetingDetail,
        arguments: meetingId, id: MeetingRoutePages.key);
  }

  void onCloseMeetingDetail(BuildContext context) {
    tapMeetingId = null;
    Navigator.pop(context);
  }
}
