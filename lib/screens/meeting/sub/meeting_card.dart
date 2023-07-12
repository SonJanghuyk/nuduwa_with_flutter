import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_detail_page.dart';
import 'dart:math' as math;

import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingCard extends StatelessWidget {
  final MeetingCardController controller;

  const MeetingCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Get.to(MeetingDetailPage(controller: controller)),
      title: SizedBox(
        height: 100,
        child: Obx(() => controller.meeting.value == null
            // 서버에서 데이터 가져오는 중일때
            ? const Center(child: CircularProgressIndicator())
            // 서버에서 데이터 가져왔을 때
            : Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HostImage, 로딩중 ProgressIndicator
                        SizedBox(
                          width: 40,
                          height: 40,
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
                            controller.meeting.value!.hostName == null
                                ? const Center(
                                    child: SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(),
                                  ))
                                : Text(
                                    controller.meeting.value!.hostName!,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                            const SizedBox(height: 3),
                            Text(
                              '${DateFormat("y년 M월 d일 a h:mm").format(controller.meeting.value!.meetingTime)}에 만나요',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                            Text(
                              controller.meeting.value!.title,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 사용자가 Host 일때
                  if (controller.userMeeting.hostUid ==
                      FirebaseService.instance.currentUid)
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: ClipPath(
                            clipper: TrapezoidClipper(),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 19, right: 8),
                            child: Transform.rotate(
                              angle: math.pi / 4, // 45도 회전
                              child: const Text(
                                'MINE',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              )),
      ),
    );
  }
}

class TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2 + 5, 0);
    path.lineTo(size.width, size.height / 2 - 5);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
