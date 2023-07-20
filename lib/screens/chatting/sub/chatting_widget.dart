import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_interface.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class ChattingWidget extends StatelessWidget {
  const ChattingWidget({
    super.key,
    required this.controller,
    required this.chatItem,
  });

  final ChattingController controller;
  final Widget Function(BuildContext, int) chatItem;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Obx(() => Stack(
                  children: [
                    ListView.builder(
                      controller: controller.scrollController,
                      itemCount: controller.messages.length,
                      itemBuilder: chatItem,
                      reverse: true,
                      shrinkWrap: true,
                    ),
                    if (controller.isNotLast.value)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: controller.scrollLast,
                          icon: const Icon(Icons.expand_circle_down_outlined),
                          iconSize: 40,
                        ),
                      )
                  ],
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
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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

                  MessageBox(text: text, sendTime: sendTime),
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
          child: MessageBox(text: text, sendTime: sendTime),
          /*Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 55),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
          ),*/
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({
    super.key,
    required this.text,
    required this.sendTime,
  });

  final String text;
  final DateTime sendTime;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ------ Text ------
        Container(
          margin: const EdgeInsets.only(right: 55),
          padding: const EdgeInsets.symmetric(
              vertical: 8, horizontal: 12),
          decoration: const BoxDecoration(
            color: Colors.grey,
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
    );
  }
}
