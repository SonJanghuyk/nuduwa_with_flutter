import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/home_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/screens/login_page.dart';
import 'package:nuduwa_with_flutter/screens/home_page.dart';
import 'package:nuduwa_with_flutter/screens/meeting/meeting_page.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Key
  await dotenv.load(fileName: 'keys.env');
 
  // 앱에 Firebase 추가
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase CRUD
  Get.put(FirebaseService());

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
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService());
      }),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: BindingsBuilder(() {
            Get.put(LoginController());
          }),
        ),
        GetPage(
          name: '/main',
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.put(HomePageController(), permanent: true);
          }),
        ),
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
          style: const TextStyle(color: Colors.black),
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
