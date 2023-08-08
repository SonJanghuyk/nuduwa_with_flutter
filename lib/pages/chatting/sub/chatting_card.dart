import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_card_controller.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';

class ChattingCard extends GetView<ChattingCardController> {
  const ChattingCard(
      {super.key, required this.chattingId, required this.onTapChattingCard});

  final String chattingId;
  final void Function() onTapChattingCard;

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
    } else if (now.year == date.year) {
      // 오늘이 아닌 경우
      return notTodayFormat.format(time);
    } else {
      // 올해가 아닌 경우
      return notThisYearFormat.format(time);
    }
  }

  @override
  String? get tag => chattingId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTapChattingCard,
      title: Container(
        padding: const EdgeInsets.all(8),
        height: 60,
        child: Obx(
          () {
            if (controller.otherUser.value==null || controller.messages.isEmpty) {
              return const Center();
            }
            final otherUser = controller.otherUser.value;
            final message = controller.messages.first;        
            final countUnreadMessages = controller.unreadCount.value;    
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      Image.network(otherUser?.imageUrl ?? '').image,
                  backgroundColor: Colors.white, // 로딩 중일 때 보여줄 배경색
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(otherUser?.name ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      message.text,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.blueGrey),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatDateTime(message.sendTime),
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 3),
                    SizedBox(
                      height: 25,                      
                      child: countUnreadMessages == 0 
                      ? null
                      : CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text('$countUnreadMessages', style: const TextStyle(color: Colors.white),),
                      )
                    )
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
