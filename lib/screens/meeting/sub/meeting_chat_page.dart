import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';

class MeetingChatPage extends StatelessWidget {
  final MeetingCardController controller;

  const MeetingChatPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          controller.meeting.value!.title,
          style: TextStyle(color: Colors.black),
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
      ),
      // const AppbarOfNuduwa(title: '미팅 title', iconButtons: [Icon(Icons.abc)],),
      body: SafeArea(
        child: Container(
          color: Colors.redAccent,
          child: Column(
            children: [
              // AnimatedList(itemBuilder: itemBuilder),
              Spacer(),
              Container(
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                    hintText: '메시지를 입력하세요',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                        borderSide: BorderSide(color: Colors.transparent)),
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
