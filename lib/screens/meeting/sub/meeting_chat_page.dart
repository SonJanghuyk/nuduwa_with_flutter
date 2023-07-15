import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MeetingChatPage extends StatelessWidget {
  final MeetingCardController controller;

  final text = ''.obs;

  MeetingChatPage({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '${controller.meeting.value!.title} (${controller.members.length})',
          style: const TextStyle(color: Colors.black),
        ),
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
          PopupMenuButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.blue,
              ),
              iconSize: 30,
              elevation: 1,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.expand(width: 150, height: 40),
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              itemBuilder: (BuildContext context) => []),
        ],
      ),
      // const AppbarOfNuduwa(title: '미팅 title', iconButtons: [Icon(Icons.abc)],),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.redAccent,
          child: Column(
            children: [
              Obx(
                () => AnimatedList(
                    key: controller.animatedlistKey,
                    initialItemCount: controller.messages.length,
                    itemBuilder: (context, index, animation) {
                      final item = controller.messages[index];
                      return SizeTransition(
                        sizeFactor: animation,
                        child: LeftChatItem(
                            imageUrl: controller.members.values.first.imageUrl,
                            name: '다온이',
                            text: item.text,
                            sendTime: item.sendTime),
                      );
                    }),
              ),

              const Spacer(),

              // Input Message TextField
              Container(
                padding: const EdgeInsets.all(16),
                child: Stack(
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
              ),
            ],
          ),
        ),
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
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(8.0),
        color: Colors.amber,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Text(name ?? '이름없음'),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(6),
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
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                        maxLines: null, // null로 설정하여 제한 없이 계산
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
                          if (lineCount > 15)
                            SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: () {
                                  // 버튼이 클릭되었을 때의 동작 처리
                                },
                                child: Text(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
