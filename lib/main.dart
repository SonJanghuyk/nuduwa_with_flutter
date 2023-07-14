import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/screens/login_page.dart';
import 'package:nuduwa_with_flutter/screens/main_page.dart';
import 'package:nuduwa_with_flutter/screens/meeting/meeting_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:flutter_config/flutter_config.dart';

import 'firebase_options.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase CRUD
    Get.put(FirebaseService());

  await FlutterConfig.loadEnvVariables();
    
  // 앱에 Firebase 추가   
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
      title: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.transparent, // 투명한 배경
      // backgroundColor: Colors.red, 
      elevation: 0, // 그림자 제거
      actions: iconButtons,
    );
  }

  @override
  // Size get preferredSize => throw UnimplementedError();
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
