import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/home_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/profileController/user_profile_controller.dart';
import 'package:nuduwa_with_flutter/screens/chatting/chatting_page.dart';
import 'package:nuduwa_with_flutter/screens/map/map_page.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/screens/meeting/meeting_page.dart';
import 'package:nuduwa_with_flutter/screens/profile/my_profile_page.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class HomePage extends StatelessWidget {
  final controller = HomePageController.instance;

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // 로딩 상태
          if (controller.permissionMessage.value == '') {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 50),
                  Text('내 위치 가져오는 중'),
                ],
              ),
            );
          }

          // 위치 권한 허가된 상태
          if (controller.permissionMessage.value == '위치 권한이 허가 되었습니다.') {
            if (controller.currentLatLng.value != null) {
              
              
              return Scaffold(
                body: Obx(
                  () => 
                  IndexedStack(
                    index: controller.tabIndex.value,
                    children: [
                      MapPage(),
                      MeetingPage(),
                      ChattingPage(),
                      MyProfilePage(),
                    ],
                  ),
                  
                ),

                // 하단 텝바
                bottomNavigationBar: Obx(
                  () => BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.map),
                        label: '찾기',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.people),
                        label: '모임',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble),
                        label: '채팅',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: '내 정보',
                      ),
                    ],

                    currentIndex: controller.tabIndex.value,
                    onTap: controller.changePage,

                    selectedItemColor: Colors.blue,
                    unselectedItemColor: Colors.grey,
                    unselectedLabelStyle: const TextStyle(fontSize: 10),
                    selectedLabelStyle: const TextStyle(fontSize: 10),

                    type: BottomNavigationBarType.fixed,
                    // backgroundColor: Colors.white,
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text('사용자 위치를 불러올 수 없습니다'),
              );
            }
          }

          // 위치 권한 없는 상태
          return Center(
            child: Text(
              controller.permissionMessage.value,
            ),
          );
        }),
      ),
    );
  }
}
