import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/model/member.dart';

Future<void> meetingInfoSheet(String meetingId) async {
  final controller = MapPageController.instance;
  controller.listenerForMembers(meetingId);
  controller
      .downloadHostImage(controller.meetings[meetingId]!.meeting.hostImageUrl);

  await showModalBottomSheet(
    context: Get.context!,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
    ),
    barrierColor: Colors.white.withOpacity(0),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (BuildContext context) => MeetingInfoScreen(meetingId: meetingId),
  );
  controller.cancelListenerForMembers(meetingId);
}

class MeetingInfoScreen extends StatelessWidget {
  final controller = MapPageController.instance;

  final String meetingId;
  final height = 220.0.obs;

  MeetingInfoScreen({
    super.key,
    required this.meetingId,
  });

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final inputDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String formattedTime = DateFormat("a h:mm").format(dateTime);

    if (inputDate == today) {
      return '오늘 $formattedTime';
    } else if (inputDate == tomorrow) {
      return '내일 $formattedTime';
    } else {
      return DateFormat("M월 d일 ").format(dateTime) + formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (dragDetails) {
        if (dragDetails.delta.dy > 0) Get.back();
        height.value = 600;
      },
      child: Obx(() {
        final meetings = controller.meetings;
        final meeting = meetings[meetingId]!.meeting;
        return AnimatedContainer(
          height: height.value,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.transparent.withOpacity(0.0)),
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // HostImage, 로딩중 ProgressIndicator
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Obx(() => controller.hostImage.value == null
                        ? const Center(child: CircularProgressIndicator())
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage: controller.hostImage.value,
                            backgroundColor: Colors.white, // 로딩 중일 때 보여줄 배경색
                          )),
                  ),
                  const SizedBox(width: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HostName, 로딩중 ProgressIndicator
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 170,
                        height: 30,
                        child:
                            controller.meetings[meetingId]!.meeting.hostName !=
                                    null
                                ? Text(
                                    controller
                                        .meetings[meetingId]!.meeting.hostName!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const Row(
                                    children: [
                                      SizedBox(width: 10),
                                      SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator()),
                                    ],
                                  ),
                      ),

                      // MeetingTime
                      Text(
                        '${formatDateTime(controller.meetings[meetingId]!.meeting.meetingTime)}에 만나요!',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // MeetingTitle
              Center(
                child: Text(
                  meeting.title,
                  style: const TextStyle(
                    fontSize: 35,
                  ),
                ),
              ),

              if (height > 300)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Spacer(),
                        RowMeetingInfo(text: controller.meetings[meetingId]!.meeting.place, icon: Icons.location_on_outlined),
                        const Spacer(),
                        RowMeetingInfo(text: controller.meetings[meetingId]!.meeting.description, icon: Icons.edit_outlined),
                        const Spacer(),
                        RowMeetingInfo(text: '${formatDateTime(controller.meetings[meetingId]!.meeting.meetingTime)}에 만날꺼에요!', icon: Icons.calendar_month),
                        const Spacer(),
                        Obx(() {
                          final countOfMembers = controller.members.length;
                          return RowMeetingInfo(text: '참여인원 $countOfMembers/${controller.meetings[meetingId]!.meeting.maxMembers}', icon: Icons.people_outline);
                        }),
                        const Spacer(),
                        Obx(
                          () => controller
                                      .meetings[meetingId]!.meeting.hostUid !=
                                  controller.firebaseService.currentUid
                              ? controller.members.any((Member member) =>
                                      member.uid ==
                                      controller.firebaseService.currentUid)
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.groups_outlined),
                                        SizedBox(width: 5),
                                        Text(
                                          '참여중',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      ],
                                    )
                                  : controller.members.length >=
                                          controller.meetings[meetingId]!
                                              .meeting.maxMembers
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.group_off_outlined),
                                            SizedBox(width: 5),
                                            Text(
                                              '인원초과',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.red),
                                            ),
                                          ],
                                        )
                                      : !controller.isLoading.value
                                          ? TextButton(
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                      Icons.group_add_outlined),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    '참여하기',
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () =>
                                                  controller.joinMeeting(
                                                      meetingId,
                                                      controller
                                                          .meetings[meetingId]!
                                                          .meeting
                                                          .hostUid,
                                                      controller
                                                          .meetings[meetingId]!
                                                          .meeting
                                                          .meetingTime),
                                            )
                                          : const CircularProgressIndicator()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class RowMeetingInfo extends StatelessWidget {
  const RowMeetingInfo({
    super.key,
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
