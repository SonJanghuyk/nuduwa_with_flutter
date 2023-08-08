import 'package:flutter/material.dart';
import 'package:get/get.dart';


// class BottomSheetBody extends StatelessWidget {
//   const BottomSheetBody({super.key, required this.children});

//   final List<Widget> children;

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//           child: Padding(
//             padding: pagePadding,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: children,
//             )
//           )
//     );
//   }
// }

void showPermissionDenied(BuildContext context, {required String permission}) {
   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$permission 권한이 없습니다.'),
        // const TextButton(
        //   onPressed: openAppSettings,
        //   child: Text('설정창으로 이동')
        // ),
      ],
    ))
  );
}

class ScaffoldOfNuduwa extends StatelessWidget {
  const ScaffoldOfNuduwa({
    super.key,
    this.scaffoldKey,
    this.appBar,
    this.body,
    this.endDrawer,
  });

  final Key? scaffoldKey;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? endDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          // constraints: const BoxConstraints(maxWidth: 650),
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 0.0,
            )
          ]),
          child: Scaffold(
            key: scaffoldKey,
            appBar: appBar,
            body: body,
            endDrawer: endDrawer,
          ),
        ),
      ),
    );
  }
}

class AppbarOfNuduwa extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppbarOfNuduwa({
    super.key,
    required this.title,
    this.actions,
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
      actions: actions,
    );
  }

  @override
  // Size get preferredSize => throw UnimplementedError();
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SnackBarOfNuduwa {

  static void warning(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.grey,
      snackPosition: SnackPosition.TOP,
    );
  }

  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void accent(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.blue,
      snackPosition: SnackPosition.TOP,
    );
  }

  static void common(String title, String message) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
    );
  }
}