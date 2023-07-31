import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_chat_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/pages/meeting/sub/meeting_chat_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/responsive.dart';

class MeetingDetailController extends GetxController {
  static MeetingDetailController instance({required String tag}) =>
      Get.find(tag: tag);

  // Listener Ref
  final CollectionReference<Member> memberColRef;

  // Meeting
  late final Rx<Meeting?> meeting;
  late final Rx<ImageProvider?> hostImage;
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
      : memberColRef = FirebaseReference.memberList(meetingId);

  @override
  void onInit() {
    super.onInit();
    fetchMeetingData();
    _snapshotMembers.bindStream(listenerForMembers());
    ever(_snapshotMembers, _fetchMembers);
  }

  void fetchMeetingData() {
    meeting = MeetingCardController.instance(tag: meetingId).meeting;
    hostImage = MeetingCardController.instance(tag: meetingId).hostImage;
  }

  // 맴버 리스너시작
  Stream<List<Member>> listenerForMembers() {
    debugPrint('모임맴버리스너!!!! ${members.length}');
    try {
      // final ref = FirebaseRoute.memberList(meetingId);

      // final listener = ref.snapshots().listen((snapshot) async {
      //   final snapshotMembers = <String, Member>{};
      //   for (final doc in snapshot.docs) {
      //     var member = doc.data();
      //     if (members[member.uid] != null) continue;
      //     snapshotMembers[member.uid] = member;

      //     // 맴버 이름, 이미지 가져오기
      //     member = await MemberRepository.read(member);
      //     snapshotMembers[member.uid] = member;
      //     members[member.uid] = member;
      //   }
      //   debugPrint(snapshotMembers.values.toString());
      //   members.value = Map.from(snapshotMembers);
      //   debugPrint('모임맴버리스너!진행중');
      // });
      final ref = FirebaseReference.memberList(meetingId);
      final stream = ref.listenAllDocuments<Member>();
      return stream;
    } catch (e) {
      debugPrint('오류!!! listenerForMembers: ${e.toString()}');
      rethrow;
    }
  }

  void _fetchMembers(List<Member> snapshotMembers) async {
    final membersMap = {
      for (final member in snapshotMembers) member.uid: member
    };

    final fetchList = <Future>[];

    membersMap.forEach((key, value) {
      if (members.containsKey(key)) {
        membersMap[key] = members[key]!;
      } else {
        fetchList.add(MemberRepository.fetchMemberNameAndImage(value).then((result) {
          membersMap[key] = result;
        }));
      }
    });
    await Future.wait(fetchList);

    members.value = membersMap;
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
    // Get.put(
    //     MeetingChatController(
    //         meetingId: meetingId,
    //         meetingTitle: meeting.value!.title,
    //         members: members),
    //     tag: meetingId);
    // Get.to(MeetingChatPage(meetingId: meetingId));
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
