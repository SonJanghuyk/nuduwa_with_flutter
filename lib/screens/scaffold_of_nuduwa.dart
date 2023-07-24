import 'package:flutter/material.dart';

class ScaffoldOfNuduwa extends StatelessWidget {
  const ScaffoldOfNuduwa({
    super.key,
    this.appBar,
    this.body,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
            spreadRadius: 0.0,
          )
        ]),
        child: Scaffold(
          appBar: appBar,
          body: body,
        ),
      ),
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
