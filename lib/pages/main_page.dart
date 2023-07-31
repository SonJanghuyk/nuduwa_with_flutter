import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/profileController/user_profile_controller.dart';
import 'package:nuduwa_with_flutter/pages/chatting/chatting_page.dart';
import 'package:nuduwa_with_flutter/pages/map/map_page.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/pages/meeting/meeting_page.dart';
import 'package:nuduwa_with_flutter/pages/profile/my_profile_page.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => const [
            MapPage(),
            MeetingPage(),
            ChattingPage(),
            MyProfilePage(),
          ][controller.tabIndex.value],
        ),
      ),

      // 하단 텝바
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 60,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map),
              label: '찾기',
              selectedIcon: Icon(Icons.map, color: Colors.white),
            ),
            NavigationDestination(
              icon: Icon(Icons.people),
              label: '모임',
              selectedIcon: Icon(Icons.people, color: Colors.white),
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble),
              label: '채팅',
              selectedIcon: Icon(Icons.chat_bubble, color: Colors.white),
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: '내 정보',
              selectedIcon: Icon(Icons.person, color: Colors.white),
            ),
          ],
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: controller.changePage,
          indicatorColor: Colors.blue,
          surfaceTintColor: Colors.white,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}
