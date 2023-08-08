import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_chat_controller.dart';
import 'package:nuduwa_with_flutter/widgets/chatting_widget.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/constants/assets.dart';

class MeetingChatPage extends GetView<MeetingChatController> {
  MeetingChatPage({
    super.key,
    required this.meetingId,
  });

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String? meetingId;

  @override
  String? get tag => meetingId;

  @override
  Widget build(BuildContext context) {
    return ScaffoldOfNuduwa(
      scaffoldKey: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Obx(() => Text(
              '${controller.title} (${controller.members.length})',
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
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.blue),
            onPressed: () => _scaffoldKey.currentState
                ?.openEndDrawer(), // Drawer를 여는 동작을 호출합니다.
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ],
      ),
      body: ChattingWidget(controller: controller, chatItem: chatItem),

      // 옆으로 나오는 sheet를 추가
      endDrawer: SafeArea(
        child: Drawer(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '대화 상대',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.members.length,
                    itemBuilder: memberCard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListTile memberCard(BuildContext context, int index) {
    final member = controller.members.values.toList()[index];
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: member.imageUrl != null
            ? NetworkImage(member.imageUrl!) as ImageProvider
            : const AssetImage(Assets.imageNoImage),
        backgroundColor: Colors.white,
      ),
      title: Text(
        member.uid == FirebaseReference.currentUid
            ? '나 - ${member.name}'
            : '${member.name}',
        style: const TextStyle(fontSize: 18),
      ),
      onTap: () => controller.showUserProfile(member.uid),
      onLongPress: () {},
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final message = controller.messages[index];
    final member = controller.members[message.senderUid];
    if (member == null) {
      debugPrint('ChatMember없음!!!');
    }
    if (message.senderUid == FirebaseReference.currentUid) {
      return RightChatItem(text: message.text, sendTime: message.sendTime);
    }

    return LeftChatItem(
      imageUrl: member?.imageUrl,
      name: member?.name,
      text: message.text,
      sendTime: message.sendTime,
    );
  }
}
