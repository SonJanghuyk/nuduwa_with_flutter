import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/main_page_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/message.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/icon_of_meeting.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_detail_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MeetingCardController extends GetxController {
  static MeetingCardController instance({required String tag}) =>
      Get.find(tag: tag);

  final firebaseService = FirebaseService.instance;

  // Listener Ref
  final meetingDocRef;
  final messageColRef;

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

  // chatting
  final messages = <Message>[].obs;
  final textController = TextEditingController();
  final animatedlistKey = GlobalKey<AnimatedListState>();

  MeetingCardController({required this.userMeeting, ImageProvider? hostImage})
      : meetingId = userMeeting.meetingId,
        meetingDocRef =
            FirebaseService.instance.meetingList.doc(userMeeting.meetingId),
        messageColRef =
            FirebaseService.instance.messageList(userMeeting.meetingId);

  @override
  void onInit() {
    super.onInit();
    listenerForMeeting(meetingId);
  }

  @override
  void onClose() {
    super.onClose();
    firebaseService.cancelListener(ref: meetingDocRef);
    firebaseService.cancelListener(ref: messageColRef);
    textController.dispose();
  }

  void listenerForMeeting(String meetingId) {
    debugPrint('listenerForMeeting: $meetingId');
    try {
      final listener = meetingDocRef.snapshots().listen((snapshot) async {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data();
        if (data?.publishedTime is! DateTime)
          data!.publishedTime = meeting.value?.publishedTime ?? DateTime.now();
        meeting.value = data;
        final temp = await firebaseService.fetchHostData(meeting.value!);
        meeting.value = Meeting.clone(temp!);
        downloadHostImage(meeting.value!.hostImageUrl);
        debugPrint('listenerForMeeting끝');
      });
      firebaseService.addListener(ref: meetingDocRef, listener: listener);
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
    debugPrint('모임맴버리스너!!!! ${members.length}');
    try {
      final ref = firebaseService.memberList(meetingId);
      debugPrint('모임맴버리스너!1');
      final listener = ref.snapshots().listen((snapshot) async {
        // final snapshotMembers2 = snapshot.docs
        //     .where((doc) => members[doc.data().uid] == null)
        //     .map((doc) {
        //       return MapEntry(doc.data().uid, doc.data(),);
        //     });
        // members.value = snapshotMembers2;
        debugPrint('모임맴버리스너!2 : ${snapshot.docs.length}');
        final snapshotMembers = <String, Member>{};
        for (final doc in snapshot.docs) {
          debugPrint('모임맴버리스너!3 :${doc.data().uid}');
          var member = doc.data();
          if (members[member.uid] != null) continue;
          snapshotMembers[member.uid] = member;
          debugPrint('모임맴버리스너!4');

          // 맴버 이름, 이미지 가져오기
          member = await firebaseService.fetchMemberData(member);
          debugPrint('모임맴버리스너!5');
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
    Get.snackbar('모임 나가기!', '"${meeting.value!.title}" 모임에서 나갔습니다',
        backgroundColor: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void listenerForMessages() {
    try {
      final listener = messageColRef.snapshots().listen((snapshot) {
        messages.value =
            snapshot.docs.map((doc) => doc.data() as Message).toList();
      });
      firebaseService.addListener(ref: messageColRef, listener: listener);
    } catch (e) {
      debugPrint('오류!! listenerForMessages: ${e.toString()}');
    }
  }

  Future<void> sendMessage() async {
    debugPrint('sendMessage');
    try {
      final text = textController.text;
      textController.clear();      
      await firebaseService.createMessageData(
          meetingId, firebaseService.currentUid!, text);
      debugPrint('sendMessage 끝');
    } catch (e) {
      debugPrint('오류!! sendMessage: ${e.toString()}');
    }
  }
}
