import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chatting_interface.dart';

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
    );
  }
}
