import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/bindings/bindings.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/pages/chatting/sub/chatting_room_page.dart';
import 'package:nuduwa_with_flutter/pages/login/login_page.dart';
import 'package:nuduwa_with_flutter/pages/main_page.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_chat_page.dart';
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
      name: '$_meetingchat/:meetingId',
      page: () =>
          MeetingChatPage(meetingId: Get.parameters['meetingId'] as String),
      binding: MeetingChatBindings(),
    ),

    GetPage(
      name: '$_chattingRoom/:otherUid',
      page: () => ChattingRoomPage(chattingId: 'chattingId', onClose: Get.back),
    ),

    // 유저 프로필 보기
    GetPage(
      name: '$_userProfile/:uid',
      page: () => UserProfilePage(),
    ),
  ];

  static const login = '/login';
  static const main = '/main';
  static const _meetingchat = '/meetingchat';
  static String meetingchat({required String meetingId}) =>
      '$main$_meetingchat/$meetingId';

  static const _chattingRoom = '/chattingRoom';
  static String chattingRoom({required String otherUid}) =>
      '$_chattingRoom/$otherUid';

  static const _userProfile = '/userProfile';
  static String userProfile({required String uid}) => '$_userProfile/$uid';
}
