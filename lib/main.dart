import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/bindings/bindings.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_themes.dart';
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

  runApp(const NuduwaApp());
}

class NuduwaApp extends StatelessWidget {
  const NuduwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Init Device Width
    Responsive.init(context);

    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false, // 디버그바 삭제
      title: 'NUDUWA',
      theme: NuduwaThemes.lightTheme,
      darkTheme: NuduwaThemes.dartTheme,
      initialBinding: NuduwaAppBindings(),
      initialRoute: RoutePages.main,
      getPages: RoutePages.pages,
    );
  }
}
