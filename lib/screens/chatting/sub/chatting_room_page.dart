import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_room_controller.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/screens/chatting/sub/chatting_widget.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingRoomPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserChatting userChatting;
  final ChattingRoomController controller;

  ChattingRoomPage({super.key, required this.userChatting})
      : controller =
            Get.put(ChattingRoomController(userChatting: userChatting));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Obx(() => Text(
              controller.otherUser.value?.name ?? '',
              style: const TextStyle(color: Colors.black),
            )),
        leading: IconButton(
          icon: const Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.arrow_back_ios, color: Colors.blue),
              Text(
                '뒤로',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ],
          ),
          onPressed: Get.back,
        ),
        leadingWidth: 100,
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.blue,
            ),
            iconSize: 30,
            elevation: 1,
            padding: EdgeInsets.zero,
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              menuItem(
                text: '상대방 프로필',
                icon: Icons.person_pin_rounded,
                color: Colors.black,
                ontap: () => controller.showUserProfile(userChatting.otherUid),
              ),
              menuItem(
                text: '나가기',
                icon: Icons.output,
                color: Colors.red,
                ontap: controller.clickedOut,
              ),
            ],
          )
        ],
      ),
      body: ChattingWidget(controller: controller, chatItem: chatItem),
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final message = controller.messages[index];
    if (message.senderUid == FirebaseService.instance.currentUid) {
      return RightChatItem(text: message.text, sendTime: message.sendTime);
    }

    return LeftChatItem(
      imageUrl: controller.otherUser.value?.imageUrl,
      name: controller.otherUser.value?.name,
      text: message.text,
      sendTime: message.sendTime,
    );
  }

  PopupMenuItem<String> menuItem(
      {required String text,
      required IconData icon,
      required Color color,
      required VoidCallback ontap}) {
    return PopupMenuItem<String>(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            icon,
            color: color,
          ),
        ],
      ),
    );
  }
}
