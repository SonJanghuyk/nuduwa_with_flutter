import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/screens/map/map_page.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/screens/profile/my_profile_page.dart';

class MainPage extends StatelessWidget {
  final controller = Get.put(MainPageController());

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 탭별 화면
    late List<Widget> tabPages = <Widget>[
      MapPage(
        controller: Get.put(MapPageController(location: controller.currentLatLng.value, userMeetings: controller.userMeetings)),
      ), // 외부 클래스로 정의
      MyProfilePage(),
    ];

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
                body: tabPages[controller.tabIndex.value],

                // 하단 텝바
                bottomNavigationBar: Obx(() => BottomNavigationBar(
                      // 현재 인덱스를 selectedIndex에 저장
                      currentIndex: controller.tabIndex.value,
                      // 요소(item)을 탭 할 시 실행
                      onTap: controller.changeIndex,
                      // 선택에 따라 icon·label 색상 변경
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.grey,
                      // 선택에 따라 label text style 변경
                      unselectedLabelStyle: const TextStyle(fontSize: 10),
                      selectedLabelStyle: const TextStyle(fontSize: 10),
                      // 탭 애니메이션 변경 (fixed: 없음)
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Colors.white,
                      // Bar에 보여질 요소. icon과 label로 구성
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.map),
                          label: '찾기',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: '내 정보',
                        ),
                      ],
                    )),
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
