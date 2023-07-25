import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/bindings/bindings.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/login_controller.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/pages/login/login_page.dart';
import 'package:nuduwa_with_flutter/pages/main_page.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_chat_page.dart';
import 'package:nuduwa_with_flutter/pages/profile/user_profile_page.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Key
  await dotenv.load(fileName: 'keys.env');

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init DateFormat
  initializeDateFormatting();
  Intl.defaultLocale = 'ko_KR';  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Init Device Width
    Responsive.init(context);
    
    return GetMaterialApp(
      title: 'NUDUWA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: MyAppBindings(),
      initialRoute: '/main',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: LoginBindings(),
        ),
        GetPage(
          name: '/main',
          page: () => const MainPage(),
          binding: MainBindings(),
        ),
        // GetPage(
        //   name: '/meeting/chat',
        //   page: () => MeetingChatPage(),
        //   binding: MeetingChatBindings(),
        // ),
        GetPage(
          name: '/userProfile',
          page: () => UserProfilePage(),
        ),
      ],
    );
  }
}


