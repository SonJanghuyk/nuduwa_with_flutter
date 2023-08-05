import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingInfoSheetController extends GetxController {
  final Meeting parameterMeeting;
  final Rx<Meeting?> meeting;
  final Rx<Meeting?> _snapshotMeeting = Rx(null);

  final members = RxList<Member>();

  final isLoading = RxBool(false);

  MeetingInfoSheetController({required this.parameterMeeting})
      : meeting = Rx(parameterMeeting);

  @override
  void onInit() {
    super.onInit();

    _snapshotMeeting.bindStream(_streamMeeting());
    ever(_snapshotMeeting, convertMeeting);

    members.bindStream(_streamMembers());
  }

  void convertMeeting(Meeting? snapshotMeeting) async {
    final tempMeeting = snapshotMeeting;
    if (meeting.value!.hostName == null) {
      final host = await UserRepository.read(meeting.value!.hostUid);
      tempMeeting!.hostName = host?.name;
      tempMeeting.hostImageUrl = host?.imageUrl;
    } else {
      tempMeeting?.hostName = meeting.value?.hostName;
      tempMeeting?.hostImageUrl = meeting.value?.hostImageUrl;
    }
    meeting.value = tempMeeting;
  }

  Stream<Meeting?> _streamMeeting() {
    return MeetingRepository.stream(meetingId: meeting.value!.id!);
  }

  Stream<List<Member>> _streamMembers() {
    return MemberRepository.listenAllDocuments(meetingId: meeting.value!.id!);
  }

  // 모임 참여하기
  void joinMeeting() async {
    isLoading.value = true;
    try {
      await MemberRepository.create(
        memberUid: FirebaseReference.currentUid!,
        meetingId: meeting.value!.id!,
        hostUid: meeting.value!.hostUid,
      );
      SnackBarOfNuduwa.accent('모임참여 성공', '모임에 참여하였습니다');
    } catch (e) {
      debugPrint('모임참여 실패 ${e.toString()}');
      SnackBarOfNuduwa.error('모임참여 실패', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
