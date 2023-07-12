import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/screens/login_page.dart';
import 'package:nuduwa_with_flutter/screens/main_page.dart';
import 'package:nuduwa_with_flutter/screens/meeting/meeting_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

import 'firebase_options.dart';

void main() async {  
  // Firebase CRUD
    Get.put(FirebaseService());
    
  // 앱에 Firebase 추가
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) => Get.put(LoginController()));  // 로그인 여부

  // DateTime DateFormat 초기화
  initializeDateFormatting();
  Intl.defaultLocale = 'ko_KR';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NUDUWA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MainPage()),        
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/main', page: () => MainPage()),
        GetPage(name: '/meeting', page: () => MeetingPage()),
      ],
    );
  }
} 

class AppbarOfNuduwa extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? iconButtons;

  const AppbarOfNuduwa({
    super.key,
    required this.title,
    this.iconButtons,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.transparent, // 투명한 배경
      elevation: 0, // 그림자 제거
      actions: iconButtons,
    );
  }

  @override
  // Size get preferredSize => throw UnimplementedError();
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
