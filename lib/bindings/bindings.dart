import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_room_controller.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_chat_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_controller.dart';
import 'package:nuduwa_with_flutter/controller/profileController/my_profile_controller.dart';
import 'package:nuduwa_with_flutter/controller/profileController/user_profile_controller.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/service/permission_service.dart';

class NuduwaAppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService());
    Get.put(PermissionService());
  }
}

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MainPageController());
    Get.put(MapPageController());
    Get.put(MeetingController());
    Get.put(ChattingPageController());
    Get.put(MyProfileController());
  }
}

class MeetingChatBindings extends Bindings {

  @override
  void dependencies() {
    final meetingId = Get.parameters['meetingId']!;
    Get.put(MeetingChatController(meetingId: meetingId), tag: meetingId);
  }
}

class ChattingRoomBindings extends Bindings {

  @override
  void dependencies() {
    final parameters = Get.parameters;
    final String userChattingId = parameters['userChattingId']!;
    final String chattingId = parameters['chattingId']!;
    final String otherUid = parameters['otherUid']!;
    Get.put(ChattingRoomController(userChattingId: userChattingId, chattingId: chattingId, otherUid: otherUid),
        tag: chattingId);
  }
}

class UserProfileBindings extends Bindings {
  
  @override
  void dependencies() {
    final uid = Get.parameters['uid']!;
    Get.put(UserProfileController(uid: uid), tag: uid);
  }
}
