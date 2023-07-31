import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_card_controller.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/pages/chatting/sub/chatting_card.dart';

class ChattingListPage extends GetView<ChattingPageController> {
  const ChattingListPage({super.key, required this.onTapChattingCard});

  final void Function(UserChatting) onTapChattingCard;

  @override
  Widget build(BuildContext context) {
    return ScaffoldOfNuduwa(
      appBar: const AppbarOfNuduwa(title: '채팅'),
      body: Obx(
        () => ListView.separated(
          itemCount: controller.userChatting.length,
          itemBuilder: (context, index) {
            final userChatting = controller.userChatting[index];
            Get.lazyPut(() => ChattingCardController(userChatting: userChatting),
                tag: userChatting.chattingId);
            return ChattingCard(
              chattingId: userChatting.chattingId,
              onTapChattingCard: () => onTapChattingCard(userChatting),
            );
          },
          separatorBuilder: (context, index) =>
              const SizedBox(height: 0, child: Divider()),
        ),
      ),
    );
  }
}
