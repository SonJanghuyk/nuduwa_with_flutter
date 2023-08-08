import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_room_controller.dart';
import 'package:nuduwa_with_flutter/widgets/chatting_widget.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChattingRoomPage extends GetView<ChattingRoomController> {
  const ChattingRoomPage({
    super.key,
    required this.chattingId,
    required this.onClose,
  });

  final String chattingId;
  final void Function() onClose;

  @override
  String? get tag => chattingId;

  @override
  Widget build(BuildContext context) {
    return ScaffoldOfNuduwa(
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
          onPressed: onClose,
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
                  ontap: () => {}),
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
    if (message.senderUid == FirebaseReference.currentUid) {
      return RightChatItem(text: message.text, sendTime: message.sendTime);
    }

    return Obx(
      () => LeftChatItem(
        imageUrl: controller.otherUser.value?.imageUrl,
        name: controller.otherUser.value?.name,
        text: message.text,
        sendTime: message.sendTime,
      ),
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
