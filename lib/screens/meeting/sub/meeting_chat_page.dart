import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_chat_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
import 'package:nuduwa_with_flutter/screens/chatting/sub/chatting_widget.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MeetingChatPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String meetingId;
  final MeetingChatController controller;
  final MeetingDetailController meetingDetailController;

  MeetingChatPage({super.key, required this.meetingId})
      : controller = Get.put(MeetingChatController(meetingId: meetingId),
            tag: meetingId),
        meetingDetailController =
            MeetingDetailController.instance(tag: meetingId);

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Obx(() => Text(
              '${MeetingCardController.instance(tag: meetingId).meeting.value!.title} (${meetingDetailController.members.length})',
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

      /*

      body: SafeArea(
        child: Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: controller.messages.length,
                        itemBuilder: chatItem,
                        reverse: true,
                      )),
                ),

                // Input Message TextField
                Stack(
                  children: [
                    TextField(
                      controller: controller.textController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.grey,
                        hintText: '메시지를 입력하세요',
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Transform.rotate(
                            angle: -45 * 0.0174533, // 라디안 변환은 각도 * 0.0174533
                            child: IconButton(
                              onPressed: controller.sendMessage,
                              icon: const Icon(Icons.send),
                              color: Colors.white,
                            ),
                          ),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      */

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
                    itemCount: meetingDetailController.members.length,
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
    final member = meetingDetailController.members.values.toList()[index];
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: member.imageUrl != null
            ? NetworkImage(member.imageUrl!) as ImageProvider
            : const AssetImage(Assets.imageNoImage),
        backgroundColor: Colors.white,
      ),
      title: Text(
        member.uid == FirebaseService.instance.currentUid
            ? '나 - ${member.name}'
            : '${member.name}',
        style: const TextStyle(fontSize: 18),
      ),
      onTap: () => controller.showUserProfile(member.uid),
      onLongPress: () {
        
      },
    );    
  }

  Widget chatItem(BuildContext context, int index) {
    final message = controller.messages[index];
    final member = meetingDetailController.members[message.senderUid];
    if (member == null) {
      debugPrint('ChatMember없음!!!');
    }
    if (message.senderUid == FirebaseService.instance.currentUid) {
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

/*
AnimatedList(
                            key: controller.listKey.value,
                            initialItemCount: messages.length,
                            itemBuilder: (context, index, animation) {
                              final item = messages[index];
                              return SizeTransition(
                                sizeFactor: animation
                                    .drive(Tween(begin: 1.0, end: 1.0)),
                                child: LeftChatItem(
                                    imageUrl: meetingDetailController
                                        .members.values.first.imageUrl,
                                    name: '다온이',
                                    text: item.text,
                                    sendTime: item.sendTime),
                              );
                            },
                          ),


                          Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: text,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            textDirection: ui.TextDirection.ltr,
                            maxLines: null, // null로 설정하여 제한 없이 계산
                          );
                          textPainter.layout(maxWidth: constraints.maxWidth);

                          final lineCount =
                              textPainter.computeLineMetrics().length;
                          textBoxWidth = textPainter.width;

                          return Column(
                            children: [
                              Text(
                                textSpan.text!,
                                maxLines: 15,
                                overflow: TextOverflow.ellipsis,
                                style: textSpan.style,
                              ),
                              if (lineCount > 15)
                                SizedBox(
                                  height: 40,
                                  child: TextButton(
                                    onPressed: () {
                                      // 버튼이 클릭되었을 때의 동작 처리
                                    },
                                    child: const Text(
                                      '더보기',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ],
                
*/