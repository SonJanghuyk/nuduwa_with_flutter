import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/controller/auth_controller.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내 정보',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent, // 투명한 배경
        elevation: 0, // 그림자 제거
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              // 검색 아이콘을 눌렀을 때 실행되는 동작
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              AuthController.instance.logout();
            },
          ),
        ],
      ),
      body: Text(AuthController.currentUser?.displayName ?? '이름없음'),
    );
  }
}