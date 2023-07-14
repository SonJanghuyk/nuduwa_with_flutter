import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_detail_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MeetingCardController extends GetxController {
  static MeetingCardController instance(String tag) => Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  // Meeting
  final UserMeeting userMeeting;
  final String meetingId;
  final meeting = Rx<Meeting?>(null);
  final hostImage = Rx<ImageProvider?>(null);
  final members = <String, Member>{}.obs;

  // Edit
  final isEdit = false.obs;
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  String? editTitle;
  String? editPlace;
  String? editDescription;

  MeetingCardController({required this.userMeeting, ImageProvider? hostImage})
      : meetingId = userMeeting.meetingId;

  @override
  void onInit() {
    super.onInit();
    listenerForMeeting(meetingId);
  }

  void listenerForMeeting(String meetingId) {
    debugPrint('listenerForMeeting: $meetingId');
    final ref = firebaseService.meetingList.doc(meetingId);
    try {
      ref.snapshots().listen((snapshot) async {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data();
        if (data?.publishedTime is! DateTime)
          data!.publishedTime = meeting.value?.publishedTime ?? DateTime.now();
        meeting.value = data;
        debugPrint('오류를 찾아보자${meeting.value?.toFirestore().toString()}');
        final temp = await firebaseService.fetchHostData(meeting.value!);
        meeting.value = Meeting.clone(temp!);
        downloadHostImage(meeting.value!.hostImageUrl);
        debugPrint('listenerForMeeting끝');
      });
    } catch (e) {
      debugPrint('에러!! listenerForMeeting: $e');
    }
  }

  Future<void> downloadHostImage(String? url) async {
    if (url == null) hostImage.value = const AssetImage(Assets.imageNoImage);
    final imageBytes = await DrawIconOfMeeting.downloadImage(url);
    hostImage.value = Image.memory(imageBytes).image;
  }

  void onTapListTile() {
    MainPageController.instance.overlayPage.value = MeetingDetailPage(
      controller: this,
      onClose: () {
        MainPageController.instance.overlayPage.value = null;
      },
    );
  }

  // 맴버 리스너시작
  void listenerForMembers(String meetingId) {
    debugPrint('모임맴버리스너!!!!');

    firebaseService.memberList(meetingId).snapshots().listen((snapshot) async {
      // final snapshotMembers2 = snapshot.docs
      //     .where((doc) => members[doc.data().uid] == null)
      //     .map((doc) {
      //       return MapEntry(doc.data().uid, doc.data(),);
      //     });
      // members.value = snapshotMembers2;
      final snapshotMembers = <String, Member>{};
      for (final doc in snapshot.docs) {
        var member = doc.data();
        if (members[member.uid] != null) continue;
        snapshotMembers[member.uid] = member;

        // 맴버 이름, 이미지 가져오기
        member = await FirebaseService.instance.fetchMemberData(member);
        snapshotMembers[member.uid] = member;
        members[member.uid] = member;
      }
      members.value = Map.from(snapshotMembers);
    });
  }

  void onEdit() {
    isEdit.value = true;
  }

  void cancelEdit() {
    isEdit.value = false;
  }

  Future<void> updateEdit() async {
    if (formKey.currentState == null) return;
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      formKey.currentState!.save();
      try {
        await firebaseService.updateMeetingData(
          meetingId: meetingId,
          title: editTitle,
          description: editDescription,
          place: editPlace,
        );
        Get.snackbar(
          '수정완료!',
          '모임 수정이 완료되었습니다!',
          backgroundColor: Colors.white,
        );
      } catch (e) {
        debugPrint('에러!!!updateEdit: ${e.toString()}');
      } finally {
        isEdit.value = false;
        isLoading.value = false;
      }
    }
  }

  Future<void> leaveMeeting() async {
    await Future.wait([
      firebaseService.deleteMemberData(
          meetingId: meetingId, uid: firebaseService.currentUid!),
      firebaseService.deleteUserMeetingData(
          meetingId: meetingId, uid: firebaseService.currentUid!)
    ]);
    MainPageController.instance.overlayPage.value = null;
    Get.snackbar(
      '모임 나가기!',
      '"${meeting.value!.title}" 모임에서 나갔습니다',
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.BOTTOM
    );    
  }
}
