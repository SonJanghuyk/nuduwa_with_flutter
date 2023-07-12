import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/main.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_info_sheet.dart';

class MeetingDetailPage extends StatelessWidget {
  final MeetingCardController controller;

  const MeetingDetailPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarOfNuduwa(
        title: '',
        iconButtons: [
          Expanded(
            child: IconButton(
              onPressed: Get.back,
              icon: const Row(children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 28,
                ),
                // SizedBox(width: 5),
                Text(
                  '내 모임',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ]),
              color: Colors.blue,
            ),
          ),
          const Spacer(),
          PopupMenuButton(itemBuilder: (BuildContext context) => [filterMenuItem()], color: Colors.blue,),
        ],
      ),
      body: Obx(() {
        final meeting = controller.meeting.value;
        if (meeting == null) {
          // 서버에서 데이터 가져오는 중일때
          return const Center(child: CircularProgressIndicator());
        } else {
          // 서버에서 데이터 가져왔을 때
          return Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(8),
            child: Expanded(
              child: Container(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        // HostImage
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Obx(() => controller.hostImage.value == null
                              ? const Center(child: CircularProgressIndicator())
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundImage: controller.hostImage.value,
                                  backgroundColor:
                                      Colors.white, // 로딩 중일 때 보여줄 배경색
                                )),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HostName
                            Text(meeting.hostName!,
                                style: const TextStyle(fontSize: 15)),
                            // PublishedTime
                            Text(
                              '${DateFormat("y년 M월 d일 a h:mm").format(meeting.publishedTime)}에 생성됨',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: Text(
                        meeting.title,
                        style: const TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold),
                      ),
                    ),
                    RowMeetingInfo(
                        text: meeting.place, icon: Icons.location_on_outlined),
                    RowMeetingInfo(
                        text: meeting.description, icon: Icons.edit_outlined),
                    RowMeetingInfo(
                        text: '${meeting.meetingTime}에 만날꺼에요!',
                        icon: Icons.calendar_month),
                  ],
                ),
              ),
            ),
          );
        }
      }),
    );
  }
  PopupMenuItem<String> filterMenuItem() {
    return PopupMenuItem<String>(
      onTap: () {},
      child: Center(
        child: Text(
          '전체',
          style: const TextStyle(
            fontSize: 23,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
