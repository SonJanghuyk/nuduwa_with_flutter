import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_card_controller.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/pages/scaffold_of_nuduwa.dart';

class ChattingPage extends GetView<ChattingPageController> {
  const ChattingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldOfNuduwa(
      appBar: const AppbarOfNuduwa(title: '채팅'),
      body: Obx(
        () => ListView.separated(
          itemCount: controller.userChatting.length,
          itemBuilder: (context, index) => ChattingCard(
            controller: Get.put(
              ChattingCardController(
                  userChatting: controller.userChatting[index]),
              tag: controller.userChatting[index].id,
            ),
          ),
          separatorBuilder: (context, index) =>
              const SizedBox(height: 0, child: Divider()),
        ),
      ),
    );
  }
}

class ChattingCard extends StatelessWidget {
  const ChattingCard({super.key, required this.controller});

  final ChattingCardController controller;

  String formatDateTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);

    final todayFormat = DateFormat('a hh:mm');
    final notTodayFormat = DateFormat('MM월 dd일 a hh:mm');
    final notThisYearFormat = DateFormat('yyyy년 MM월 dd일 a hh:mm');

    if (today.compareTo(date) == 0) {
      // 오늘인 경우      
      return todayFormat.format(time);

    } else if (now.year == date.year){
      // 오늘이 아닌 경우
      return notTodayFormat.format(time);

    } else {
      // 올해가 아닌 경우
      return notThisYearFormat.format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 50,
        child: Obx(
          () => Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    Image.network(controller.otherUser.value?.imageUrl ?? '')
                        .image,
                backgroundColor: Colors.white, // 로딩 중일 때 보여줄 배경색
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(controller.otherUser.value?.name ?? '',
                      style: const TextStyle(fontSize: 16)),
                  Text(controller.message.first.text,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              const Spacer(),
              Text(formatDateTime(controller.message.first.sendTime),
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
