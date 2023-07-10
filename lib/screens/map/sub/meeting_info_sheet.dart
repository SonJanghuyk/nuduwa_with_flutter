import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/mapController/map_page_controller.dart';
import 'package:nuduwa_with_flutter/model/member.dart';

Future<void> meetingInfoSheet(String meetingId) async {
  final controller = MapPageController.instance;
  controller.listenerForMembers(meetingId);

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
      child: Obx(
        () => AnimatedContainer(
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
                    child: controller.meetings[meetingId]!.$1.hostImageUrl != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              controller.meetings[meetingId]!.$1.hostImageUrl!,
                            ),
                          )
                        : const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ),
                  const SizedBox(width: 30),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HostName, 로딩중 ProgressIndicator
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 170,
                        height: 30,
                        child: controller.meetings[meetingId]!.$1.hostName !=
                                null
                            ? Text(
                                controller.meetings[meetingId]!.$1.hostName!,
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
                        '${formatDateTime(controller.meetings[meetingId]!.$1.meetingTime)}에 만나요!',
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
                  controller.meetings[meetingId]!.$1.title,
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
                        rowMeetingInfo(
                          controller.meetings[meetingId]!.$1.place,
                          Icons.location_on_outlined,
                        ),
                        const Spacer(),
                        rowMeetingInfo(
                          controller.meetings[meetingId]!.$1.description,
                          Icons.edit_outlined,
                        ),
                        const Spacer(),
                        rowMeetingInfo(
                          '${formatDateTime(controller.meetings[meetingId]!.$1.meetingTime)}에 만날꺼에요!',
                          Icons.calendar_month,
                        ),
                        const Spacer(),
                        Obx(() {
                          final countOfMembers = controller.members.length;
                          return rowMeetingInfo(
                              '참여인원 $countOfMembers/${controller.meetings[meetingId]!.$1.maxMemers}',
                              Icons.people_outline);
                        }),
                        const Spacer(),
                        Obx(
                          () => controller.meetings[meetingId]!.$1.hostUid !=
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
                                              fontSize: 18, color: Colors.black),
                                        ),
                                      ],
                                    )
                                  : controller.members.length >=
                                          controller
                                              .meetings[meetingId]!.$1.maxMemers
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
                                              onPressed: () => controller
                                                  .joinMeeting(meetingId, controller.meetings[meetingId]!.$1.hostUid, controller.meetings[meetingId]!.$1.meetingTime),
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
        ),
      ),
    );
  }

  Row rowMeetingInfo(String text, IconData icon) {
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
