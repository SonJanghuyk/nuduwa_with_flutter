import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/home_page_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingDetailController extends GetxController {
  static MeetingDetailController instance({required String tag}) =>
      Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  // Listener Ref
  final CollectionReference<Member> memberColRef;

  // Meeting
  final String meetingId;
  final members = <String, Member>{}.obs;

  // Edit
  final isEdit = false.obs;
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  String? editTitle;
  String? editPlace;
  String? editDescription;

  MeetingDetailController({required this.meetingId})
      : memberColRef =
            FirebaseService.instance.memberList(meetingId);

  @override
  void onInit() {
    super.onInit();
    listenerForMembers();
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: memberColRef);
  }

  void close() {
    HomePageController.instance.overlayPage.value = null;
  }

  // 맴버 리스너시작
  void listenerForMembers() {
    debugPrint('모임맴버리스너!!!! ${members.length}');
    try {
      final ref = firebaseService.memberList(meetingId);
      final listener = ref.snapshots().listen((snapshot) async {
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
          member = await MemberRepository.instance.fetchMemberData(member);
          snapshotMembers[member.uid] = member;
          members[member.uid] = member;
        }
        debugPrint(snapshotMembers.values.toString());
        members.value = Map.from(snapshotMembers);
        debugPrint('모임맴버리스너!진행중');
      });
      firebaseService.addListener(ref: ref, listener: listener);
    } catch (e) {
      debugPrint('오류!!! listenerForMembers: ${e.toString()}');
    }
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
        await MeetingRepository.instance.updateMeetingData(
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
      MemberRepository.instance.deleteMemberData(
          meetingId: meetingId, uid: firebaseService.currentUid!),
      UserMeetingRepository.instance.deleteUserMeetingData(
          meetingId: meetingId, uid: firebaseService.currentUid!)
    ]);
    HomePageController.instance.overlayPage.value = null;
    Get.snackbar('모임 나가기!', '"${MeetingCardController.instance(tag: meetingId).meeting.value!.title}" 모임에서 나갔습니다',
        backgroundColor: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }
}
