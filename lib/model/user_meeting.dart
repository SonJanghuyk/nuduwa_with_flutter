import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/firebase_manager.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/user.dart';

class UserMeeting {
  final String? id;
  final String meetingId;
  final String hostUid;
  final bool isEnd;
  final List<String>? nonReviewMembers;
  final DateTime meetingDate;

  UserMeeting({
    this.id,
    required this.meetingId,
    required this.hostUid,
    required this.isEnd,
    this.nonReviewMembers,
    required this.meetingDate,
  });

  factory UserMeeting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final meetingId = data?['meetingId'] as String?;
    final hostUid = data?['hostUid'] as String?;
    final isEnd = data?['isEnd'] as bool?;
    final meetingDate = data?['meetingDate'] as Timestamp?;
    if (meetingId == null ||
        hostUid == null ||
        isEnd == null ||
        meetingDate == null) {
      return throw '에러! something is null';
    }

    return UserMeeting(
      id: snapshot.id,
      meetingId: meetingId,
      hostUid: hostUid,
      isEnd: isEnd,
      nonReviewMembers: data?['nonReviewMembers'] as List<String>?,
      meetingDate: meetingDate.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "meetingId": meetingId,
      "hostUid": hostUid,
      "isEnd": isEnd,
      "nonReviewMembers": nonReviewMembers,
      "meetingDate": meetingDate,
    };
  }
}

class UserMeetingManager extends UserManager {
  static UserMeetingManager get instance => Get.find();

  Future<void> createUserMeetingData(String meetingId, String hostUid, DateTime meetingTime) async {
    final userMeeting = UserMeeting(meetingId: meetingId, hostUid: hostUid, isEnd: false, meetingDate: meetingTime);
    final ref = userMeetingList(currentUid!).doc();
    await ref.set(userMeeting);
  }

  Future<void> deleteUserMeetingData(String meetingId, String uid) async {
    final query = userMeetingList(uid).where('meetingId', isEqualTo: meetingId);
    final snapshot = await query.get();
    final ref = snapshot.docs.first.reference;
    await ref.delete();
  }

  Future<UserMeeting?> readMemberData(String meetingId, String uid) async {
    final ref = userMeetingList(uid).where('meetingId', isEqualTo: meetingId);
    var snapshot = await ref.get();

    return snapshot.docs.first.data();
  }
}
