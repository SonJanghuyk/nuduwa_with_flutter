import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_list_controller.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_detail_page.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_list_page.dart';
import 'package:nuduwa_with_flutter/screens/scaffold_of_nuduwa.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingPage extends StatelessWidget {
  MeetingPage({super.key});

  final controller = Get.put(MeetingController());

  @override
  Widget build(BuildContext context) {    
    return Responsive.layout(
      mobile: Navigator(
        key: Get.nestedKey(1),
        initialRoute: '/meeting',
        onGenerateRoute: ((settings) {
          switch (settings.name) {
            case '/meeting':
              return GetPageRoute(
                settings: settings,
                page: () => MeetingListPage(),
                transition: Transition.noTransition,
              );

            case '/meeting/detail':
              final meetingId = settings.arguments as String;
              return GetPageRoute(
                settings: settings,
                page: () => MeetingDetailPage(meetingId: meetingId),
                binding: BindingsBuilder(() {
                  Get.put(MeetingDetailController(meetingId: meetingId),
                      tag: meetingId);
                }),
                transition: Transition.noTransition,
              );

            default:
              return null;
          }
        }),
      ),
      tablet: landscapeWidget(),
      desktop: landscapeWidget(),
    );
  }

  Row landscapeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MeetingListPage(),
        ScaffoldOfNuduwa(
          body: Navigator(
            key: Get.nestedKey(1),
            initialRoute: '/meeting/empty',
            onGenerateRoute: ((settings) {
              switch (settings.name) {
                case '/meeting/empty':
                  return GetPageRoute(
                    settings: settings,
                    page: () => const MeetingDetailNullPage(),
                    transition: Transition.noTransition,
                  );
                case '/meeting/detail':
                  final meetingId = settings.arguments as String;
                  return GetPageRoute(
                    settings: settings,
                    page: () => MeetingDetailPage(meetingId: meetingId),
                    binding: BindingsBuilder(() {
                      Get.put(MeetingDetailController(meetingId: meetingId),
                          tag: meetingId);
                    }),
                    transition: Transition.noTransition,
                  );
        
                default:
                  return null;
              }
            }),
          ),
        ),
      ],
    );
  }
}

class MeetingDetailNullPage extends StatelessWidget {
  const MeetingDetailNullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('왼쪽에서 모임을 클릭해주세요'),
    );
  }
}
