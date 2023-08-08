import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/bindings/bindings.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';
import 'package:nuduwa_with_flutter/pages/chatting/sub/chatting_room_page.dart';
import 'package:nuduwa_with_flutter/pages/login/login_page.dart';
import 'package:nuduwa_with_flutter/pages/main_page.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_chat_page.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_detail_page.dart';
import 'package:nuduwa_with_flutter/pages/profile/user_profile_page.dart';

class RoutePages {
  static final List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: LoginBindings(),
    ),
    GetPage(
      name: main,
      page: () => const MainPage(),
      binding: MainBindings(),
    ),

    // MeetingDetailPage -> MeetingChatPage
    GetPage(
      name: '/meetingchat/:meetingId',
      page: () =>
          MeetingChatPage(meetingId: Get.parameters['meetingId'] as String),
      binding: MeetingChatBindings(),
    ),

    GetPage(
      name: '/chattingRoom/:userChattingId',
      page: () => ChattingRoomPage(chattingId: Get.parameters['chattingId'] as String, onClose: Get.back),
      binding: ChattingRoomBindings(),
    ),

    // 유저 프로필 보기
    GetPage(
      name: '/userProfile/:uid',
      page: () => UserProfilePage(uid: Get.parameters['uid'] as String),
      binding: UserProfileBindings(),
    ),
  ];

  static const login = '/login';
  static const main = '/main';
  
  static String meetingchat({required String meetingId}) =>
      '/meetingchat/$meetingId';

  static String chattingRoom({required UserChatting userChatting}) =>
      '/chattingRoom/${userChatting.id}?chattingId=${userChatting.chattingId}&otherUid=${userChatting.otherUid}';

  static String userProfile({required String uid}) => '/userProfile/$uid';

  static const meeting = '/meeting';
}

class MeetingRoutePages {
  static GetPageRoute detailPage(String meetingId, void Function(BuildContext) onClose) => GetPageRoute(
        page: () => MeetingDetailPage(meetingId: meetingId, onClose: onClose),
        binding: BindingsBuilder<MeetingDetailController>(() {
          Get.put(MeetingDetailController(meetingId: meetingId),
              tag: meetingId);
        }),
      );
      
  static const meetingDetail = '/detail';
  static const key = 1;
}
