import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_card_controller.dart';
import 'package:nuduwa_with_flutter/utils/format_datetime.dart';

class ChattingCard extends GetView<ChattingCardController> {
  const ChattingCard(
      {super.key, required this.chattingId, required this.onTapChattingCard});

  final String chattingId;
  final void Function() onTapChattingCard;  

  @override
  String? get tag => chattingId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTapChattingCard,
      title: Container(
        padding: const EdgeInsets.all(8),
        height: 70,
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
                    Text(FormatDateTime.simple(message.sendTime),
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
