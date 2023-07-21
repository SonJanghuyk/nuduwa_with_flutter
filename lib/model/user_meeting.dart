import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class UserMeeting {
  final String? id;
  final String meetingId;
  final String hostUid;
  final bool isEnd;
  final List<String>? nonReviewMembers;

  UserMeeting({
    this.id,
    required this.meetingId,
    required this.hostUid,
    required this.isEnd,
    this.nonReviewMembers,
  });

  factory UserMeeting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final meetingId = data?['meetingId'] as String?;
    final hostUid = data?['hostUid'] as String?;
    final isEnd = data?['isEnd'] as bool?;
    if (meetingId == null || hostUid == null || isEnd == null) {
      return throw '에러! something is null';
    }

    return UserMeeting(
      id: snapshot.id,
      meetingId: meetingId,
      hostUid: hostUid,
      isEnd: isEnd,
      nonReviewMembers: data?['nonReviewMembers'] as List<String>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "meetingId": meetingId,
      "hostUid": hostUid,
      "isEnd": isEnd,
    };
  }
}

class UserMeetingRepository {
  static final UserMeetingRepository instance =
      UserMeetingRepository._internal();

  UserMeetingRepository._internal();

  final firebase = FirebaseService.instance;

  Future<DocumentReference<UserMeeting>?> createUserMeetingData(
      String meetingId, String hostUid) async {
    if (firebase.currentUid == null) {
      debugPrint('createUserMeetingData에러: no CurrentUid');
      return null;
    }

    final userMeeting =
        UserMeeting(meetingId: meetingId, hostUid: hostUid, isEnd: false);

    final ref = firebase.userMeetingList(firebase.currentUid!).doc();

    try {
      await ref.set(userMeeting);
      return ref;
    } catch (e) {
      debugPrint('createUserMeetingData에러: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteUserMeetingData(
      {required String meetingId, required String uid}) async {
    final query =
        firebase.userMeetingList(uid).where('meetingId', isEqualTo: meetingId);

    try {
      final snapshot = await query.get();
      final ref = snapshot.docs.first.reference;
      await ref.delete();
    } catch (e) {
      debugPrint('deleteUserMeetingData에러: ${e.toString()}');
      rethrow;
    }
  }

  Future<UserMeeting?> readUserMeetingData(String meetingId, String uid) async {
    final ref =
        firebase.userMeetingList(uid).where('meetingId', isEqualTo: meetingId);

    try {
      final snapshot = await ref.get();
      return snapshot.docs.first.data();
    } catch (e) {
      debugPrint('readUserMeetingData에러: ${e.toString()}');
      rethrow;
    }
  }
}
