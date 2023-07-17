import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_chat_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
          onPressed: () => Get.back(),
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
      body: SafeArea(
        child: Expanded(
          child: Container(
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

      // 옆으로 나오는 sheet를 추가
      endDrawer: SafeArea(
        child: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 0, 0),
                child: Text(
                  '대화 상대',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
        style: TextStyle(fontSize: 18),
      ),
      onTap: () {
        showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              46, // 리스트 항목 측정값을 기준으로 메뉴의 가로 위치 조절
              kToolbarHeight +
                  (index * 56), // 툴바 높이와 항목 높이(56)를 고려하여 메뉴 세로 위치 조절
              0, // 상단
              0, // 하단
            ),
            items: [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ]);
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

class LeftChatItem extends StatelessWidget {
  const LeftChatItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.text,
    required this.sendTime,
  });

  final String? imageUrl;
  final String? name;
  final String text;
  final DateTime sendTime;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.all(6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------ Image ------
            CircleAvatar(
              radius: 20,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl!) as ImageProvider
                  : const AssetImage(Assets.imageNoImage),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------ Name ------
                  Text(name ?? '이름없음'),
                  const SizedBox(height: 4),

                  Stack(
                    children: [
                      // ------ Text ------
                      Container(
                        margin: const EdgeInsets.only(right: 55),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        // text 몇줄인지 계산
                        child: LayoutBuilder(builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: text,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            textDirection: ui.TextDirection.ltr,
                            maxLines: null,
                          );
                          textPainter.layout(maxWidth: constraints.maxWidth);

                          final lineCount =
                              textPainter.computeLineMetrics().length;

                          return Column(
                            children: [
                              Text(
                                textSpan.text!,
                                maxLines: 15,
                                overflow: TextOverflow.ellipsis,
                                style: textSpan.style,
                              ),
                              // ------ Text 15줄 초과되었을때 자르고 더보기 버튼 생성 ------
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

                      // ------ SendTime ------
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          width: 52,
                          child: Text(
                            DateFormat('a h:mm').format(sendTime),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightChatItem extends StatelessWidget {
  const RightChatItem({
    super.key,
    required this.text,
    required this.sendTime,
  });

  final String text;
  final DateTime sendTime;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: const EdgeInsets.all(6.0),
        child: Align(
          alignment: Alignment.topRight,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 55),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                // text 몇줄인지 계산
                child: LayoutBuilder(builder: (context, constraints) {
                  final textSpan = TextSpan(
                    text: text,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  );
                  final textPainter = TextPainter(
                    text: textSpan,
                    textDirection: ui.TextDirection.ltr,
                    maxLines: null,
                  );
                  textPainter.layout(maxWidth: constraints.maxWidth);

                  final lineCount = textPainter.computeLineMetrics().length;

                  return Column(
                    children: [
                      Text(
                        textSpan.text!,
                        maxLines: 15,
                        overflow: TextOverflow.ellipsis,
                        style: textSpan.style,
                      ),
                      // ------ Text 15줄 초과되었을때 자르고 더보기 버튼 생성 ------
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

              // ------ SendTime ------
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 52,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormat('a h:mm').format(sendTime),
                    style:
                        const TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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