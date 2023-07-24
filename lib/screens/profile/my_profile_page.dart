import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/screens/scaffold_of_nuduwa.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';

class MyProfilePage extends StatelessWidget {
  final controller = LoginController.instance;

  MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('ㅇㅇ${Get.arguments}');
    return Scaffold(
      appBar: AppbarOfNuduwa(
        title: '내 정보',
        iconButtons: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              // 검색 아이콘을 눌렀을 때 실행되는 동작
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              AuthService.instance.logout();
            },
          ),
        ],
      ),
      // body: Text(controller.firebaseService.currentUid ?? '이름없음'),
    );
  }
}
