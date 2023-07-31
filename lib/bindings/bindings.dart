import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_chat_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_controller.dart';
import 'package:nuduwa_with_flutter/controller/profileController/my_profile_controller.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
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
    Get.put(MainPageController(), permanent: true);
    Get.put(MapPageController());
    Get.put(MeetingController());
    Get.put(ChattingPageController());
    Get.put(MyProfileController());
  }
}

class MeetingChatBindings extends Bindings {

  @override
  void dependencies() {
    final meetingId = Get.parameters['meetingId'] as String;
    Get.put(MeetingChatController(meetingId: meetingId), tag: meetingId);
  }
}
