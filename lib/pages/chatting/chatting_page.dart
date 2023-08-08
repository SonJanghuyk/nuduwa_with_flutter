import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/chattingController/chatting_room_controller.dart';
import 'package:nuduwa_with_flutter/pages/chatting/sub/chatting_list_page.dart';
import 'package:nuduwa_with_flutter/pages/chatting/sub/chatting_room_page.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class ChattingPage extends GetView<ChattingPageController> {
  const ChattingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Responsive.layout(
      portrait: Obx(
        () => Stack(
          children: [
            ChattingListPage(onTapChattingCard: controller.onTapChattingCard),
            if (controller.isOnTap.value) chattingRoomBuilder()
          ],
        ),
      ),
      landscape: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: ChattingListPage(
                onTapChattingCard: controller.onTapChattingCard),
          ),
          Expanded(
            flex: 2,
            child: Obx(() {
              if (!controller.isOnTap.value) {
                return const ChattingNullPage();
              } else {
                return chattingRoomBuilder();
              }
            }),
          ),
        ],
      ),
    );
  }

  GetBuilder<ChattingRoomController> chattingRoomBuilder() {
    return GetBuilder(
      key: GlobalKey(),
      // init: ChattingRoomController(userChatting: controller.tapUserChatting!),
      tag: controller.tapUserChatting!.chattingId,
      builder: (_) => ChattingRoomPage(
        chattingId: controller.tapUserChatting!.chattingId,
        onClose: controller.onCloseChattingRoom,
      ),
    );
  }
}

class ChattingNullPage extends StatelessWidget {
  const ChattingNullPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldOfNuduwa(
      body: Center(
        child: Text('왼쪽에서 채팅을 클릭해주세요'),
      ),
    );
  }
}
