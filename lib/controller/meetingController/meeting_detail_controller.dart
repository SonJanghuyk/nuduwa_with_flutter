import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingDetailController extends GetxController {
  static MeetingDetailController instance({required String tag}) =>
      Get.find(tag: tag);

  // Meeting
  final Rx<Meeting?> meeting;
  final String meetingId;
  final members = RxMap<String, Member>();
  final _snapshotMembers = RxList<Member>();

  // Edit
  final isEdit = false.obs;
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  String? editTitle;
  String? editPlace;
  String? editDescription;

  MeetingDetailController({required this.meetingId})
      : meeting = MeetingCardController.instance(tag: meetingId).meeting;

  @override
  void onInit() {
    super.onInit();

    // 서버와 실시간 연동
    _snapshotMembers.bindStream(streamForMembers());
    ever(_snapshotMembers, _fetchMembers);
  }

  // 맴버 리스너시작
  Stream<List<Member>> streamForMembers() {
    debugPrint('모임맴버리스너!!!! ${members.length}');
    try {
      final ref = FirebaseReference.memberList(meetingId);
      final stream = ref.streamAllDocuments<Member>();
      return stream;
    } catch (e) {
      debugPrint('오류!!! listenerForMembers: ${e.toString()}');
      rethrow;
    }
  }

  void _fetchMembers(List<Member> snapshotMembers) async {
    // 새로운 맴버 데이터
    // 서버 SnapshotMembers 데이터에 대한 기존 Members 데이터의 차집합
    // member.id로 데이터 비교
    final newMembers = snapshotMembers
        .where((snapshotMember) => !members.values
            .map((member) => member.id)
            .contains(snapshotMember.id))
        .toList();

    // 새로운 맴버 데이터 이름과 이미지 가져오기
    final fetchNewMembers = await Future.wait(
      [for (final member in newMembers) MemberRepository.fetchMemberNameAndImage(member)]
    );

    // NewMembers Map으로 변환
    final mapOfFetchNewMembers = {
      for (final member in fetchNewMembers)
        member.uid: member
    };

    // 서버 SnapshotMembers 데이터에 대한 기존 Members 데이터의 교집합
    final fetchMembers = Map.fromEntries(members.entries.where((entry) => snapshotMembers.map((snapshotMember) => snapshotMember.id).contains(entry.value.id))); 
    
    // 차집합이랑 교집합 합치기
    fetchMembers.addAll(mapOfFetchNewMembers);

    // Rx변수에 적용
    members.value = fetchMembers;
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
        await MeetingRepository.update(
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

  void enterMeetingChat() {
    Get.toNamed(RoutePages.meetingchat(meetingId: meetingId));
  }

  Future<void> leaveMeeting() async {
    await Future.wait([
      MemberRepository.delete(
          meetingId: meetingId, uid: FirebaseReference.currentUid!),
      UserMeetingRepository.delete(
          meetingId: meetingId, uid: FirebaseReference.currentUid!)
    ]);
    Get.back();
    Get.snackbar('모임 나가기!',
        '"${MeetingCardController.instance(tag: meetingId).meeting.value!.title}" 모임에서 나갔습니다',
        backgroundColor: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }
}
