import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/mapController/meeting_info_sheet_controller.dart';
import 'package:nuduwa_with_flutter/models/meeting.dart';
import 'package:nuduwa_with_flutter/models/member.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/constants/assets.dart';

void meetingInfoSheet(Meeting meeting) {
  showModalBottomSheet(
    context: Get.context!,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      Get.put(MeetingInfoSheetController(parameterMeeting: meeting), tag: meeting.id);
      return MeetingInfoScreen(meetingId: meeting.id!);
    }
  );
}

class MeetingInfoScreen extends GetView<MeetingInfoSheetController> {
  final String meetingId;
  final height = 220.0.obs;

  MeetingInfoScreen({
    super.key,
    required this.meetingId,
  });

  @override
  String? get tag => meetingId;

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
        if (dragDetails.delta.dy > 5) Get.back();
        height.value = 600;
      },
      onDoubleTap: () => height.value = 600,
      child: Obx(
        () {
          final meeting = controller.meeting.value!;
          return AnimatedContainer(
            height: height.value,
            // width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(20),
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // HostImage
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircleAvatar(
                        radius: 20,
                        foregroundImage:
                            Image.network(meeting.hostImageUrl!).image,
                        backgroundImage: Image.asset(Assets.imageLoading)
                            .image, // 로딩 중일 때 보여줄 이미지
                      ),
                    ),
                    const SizedBox(width: 30),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HostName
                        SizedBox(
                          // width: MediaQuery.of(context).size.width - 170,
                          height: 40,
                          child: meeting.hostName != null
                              ? Text(
                                  meeting.hostName!,
                                  style: const TextStyle(
                                    fontSize: 30,
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
                          '${formatDateTime(meeting.meetingTime)}에 만나요!',
                          style: const TextStyle(
                            fontSize: 20,
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
                      child: Obx(
                        () {
                          final members = controller.members;

                          return Column(
                            children: [
                              const Spacer(),
                              RowMeetingInfo(
                                  text: meeting.place,
                                  icon: Icons.location_on_outlined),
                              const Spacer(),
                              RowMeetingInfo(
                                  text: meeting.description,
                                  icon: Icons.edit_outlined),
                              const Spacer(),
                              RowMeetingInfo(
                                  text:
                                      '${formatDateTime(meeting.meetingTime)}에 만날꺼에요!',
                                  icon: Icons.calendar_month),
                              const Spacer(),
                              RowMeetingInfo(
                                  text:
                                      '참여인원 ${members.length}/${meeting.maxMembers}',
                                  icon: Icons.people_outline),
                              const Spacer(),
                              joinButton(meeting, members),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Builder joinButton(Meeting meeting, RxList<Member> members) {
    return Builder(builder: (context) {
      final isHost = meeting.hostUid == FirebaseReference.currentUid;
      final isJoin = members
          .any((Member member) => member.uid == FirebaseReference.currentUid);
      final isFull = members.length >= meeting.maxMembers;
      final isLoading = controller.isLoading.value;

      if (isHost) {
        return const Center();
      } else if (isJoin) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined),
            SizedBox(width: 5),
            Text(
              '참여중',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        );
      } else if (isFull) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_outlined),
            SizedBox(width: 5),
            Text(
              '인원초과',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        );
      } else if (isLoading) {
        return const CircularProgressIndicator();
      } else {
        return TextButton(
          onPressed: controller.joinMeeting,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_add_outlined),
              SizedBox(width: 5),
              Text(
                '참여하기',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        );
      }
    });
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
