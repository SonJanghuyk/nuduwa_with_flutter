import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingController extends GetxController {
  static MeetingController get instance => Get.find();

  @override
  void onReady() {
    super.onReady();
    if(Responsive.deviceSize != DeviceSize.mobile) {
      Get.toNamed('/meeting/empty', id: 1);
    }
  }
}
