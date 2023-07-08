import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/auth_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/screens/login_page.dart';
import 'package:nuduwa_with_flutter/screens/main_page.dart';

import 'firebase_options.dart';

void main() async {
  // Model Manager GetPut
  Get.put(UserManager());
  Get.put(MeetingManager());  
  Get.lazyPut(() => MemberManager());
  // 앱에 Firebase 추가
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((_) => Get.put(AuthController()));  // 로그인 토큰이 있으면 바로 로그인 

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
        GetPage(name: '/loginPage', page: () => LoginPage()),
      ],
      // home: MainPage(),
    );
  }
} 

