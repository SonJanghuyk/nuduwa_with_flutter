import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/screens/login_screen.dart';
import 'package:nuduwa_with_flutter/screens/controller/main_screen_controller.dart';
import 'package:nuduwa_with_flutter/screens/map/map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  int _tapIndex = 0;

  @override
  Widget build(BuildContext context) {
    MainScreenController controller = Get.put(MainScreenController());

    // 탭별 화면
    List<Widget> tabPages = <Widget>[
      MapScreen(
        currentLatLng: controller.currentLatLng,
      ), // 외부 클래스로 정의
      LoginScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: GetBuilder<MainScreenController>(builder: (_) {
          // 로딩 상태
          if (controller.permissionMessage == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 위치 권한 허가된 상태
          if (controller.permissionMessage == '위치 권한이 허가 되었습니다.') {
            // 로그인 여부 확인
            if (controller.currentUser.value == null) {
              return const LoginScreen();
            }

            return Scaffold(
              body: Obx(() => tabPages[controller.tabIndex.value]),
              bottomNavigationBar: Obx(() => BottomNavigationBar(
                // 현재 인덱스를 selectedIndex에 저장
                currentIndex: controller.tabIndex.value,
                // 요소(item)을 탭 할 시 실행
                onTap: controller.changeIndex,
                // 선택에 따라 icon·label 색상 변경
                selectedItemColor: context.theme.colorScheme.onBackground,
                unselectedItemColor: context.theme.colorScheme.onSurfaceVariant,
                // 선택에 따라 label text style 변경
                unselectedLabelStyle: TextStyle(fontSize: 10),
                selectedLabelStyle: TextStyle(fontSize: 10),
                      // 탭 애니메이션 변경 (fixed: 없음)
                type: BottomNavigationBarType.fixed,
                backgroundColor: context.theme.colorScheme.background,
                // Bar에 보여질 요소. icon과 label로 구성
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    label: '찾기',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.login),
                    label: '로그인',
                  ),
                ],
              ))
            );
          }

          // 위치 권한 없는 상태
          return Center(
            child: Text(
              controller.permissionMessage!,
            ),
          );
        }),
      ),
    );
  }
}
