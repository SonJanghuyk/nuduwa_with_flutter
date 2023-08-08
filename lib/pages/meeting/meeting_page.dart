import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_controller.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_list_page.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingPage extends GetView<MeetingController> {
  const MeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Responsive.layout(
      portrait: meetingNavigator(controller.onTapMeetingCardAtPortrait, controller.onCloseMeetingDetail),
      landscape: Row(
        children: [
          Expanded(
            child: MeetingListPage(
              onTap: controller.onTapMeetingCardAtlandscape,
            ),
          ),
          Expanded(
            child: meetingNavigator(controller.onTapMeetingCardAtPortrait, controller.onCloseMeetingDetail),
          ),
        ],
      ),
    );
  }

  Navigator meetingNavigator(void Function(String) onTapCard,  void Function(BuildContext) onClose) {
    return Navigator(
      key: Get.nestedKey(MeetingRoutePages.key),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == MeetingRoutePages.meetingDetail) {
          final meetingId = settings.arguments as String;
          return MeetingRoutePages.detailPage(meetingId, onClose);
        } else {
          return GetPageRoute(
            page: () => MeetingResponsivePage(onTapCardPortrait: onTapCard),
          );
        }
      },
    );
  }
}

class MeetingResponsivePage extends StatelessWidget {
  const MeetingResponsivePage({super.key, required this.onTapCardPortrait});

  final void Function(String)? onTapCardPortrait;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Responsive.layout(
      portrait: MeetingListPage(
        onTap: onTapCardPortrait ?? (_){},
      ),
      landscape: const ScaffoldOfNuduwa(
        body: Center(
          child: Text('왼쪽에서 모임을 클릭해주세요'),
        ),
      ),
    );
  }
}
