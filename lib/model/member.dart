import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class Member {
  final String? id;
  final String uid;
  String? name;
  String? imageUrl;
  final DateTime? joinTime;

  Member({
    this.id,
    required this.uid,
    this.name,
    this.imageUrl,
    this.joinTime,
  });

  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final joinTime = data?['joinTime'] as Timestamp?;
    if (joinTime == null) {
      return throw '에러! joinTime is null';
    }
    return Member(
      id: snapshot.id,
      uid: data?['uid'] as String,
      name: data?['name'] as String?,
      imageUrl: data?['image'] as String?,
      joinTime: joinTime.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      if (name != null) "name": name,
      if (imageUrl != null) "image": imageUrl,
      "joinTime": FieldValue.serverTimestamp(),
    };
  }

  factory Member.clone(Member member) {
    return Member(
      id: member.id,
      uid: member.uid,
      name: member.name,
      imageUrl: member.imageUrl,
      joinTime: member.joinTime,
    );
  }
}

class MemberRepository {

  /// Create Member Data
  static Future<DocumentReference<Member>?> create(
      {required String memberUid,
      required String meetingId,
      required String hostUid}) async {
    final member = Member(uid: memberUid);
    final ref = FirebaseReference.memberList(meetingId).doc();
    try {
      await Future.wait([
        ref.set(member),
        UserMeetingRepository.create(uid: memberUid, meetingId: meetingId, hostUid: hostUid),
      ]);
      return ref;
    } catch (e) {
      debugPrint('createMemberData에러: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Read Member Data
  static Future<Member?> read(String meetingId, String uid) async {
    final query = FirebaseReference.memberList(meetingId).where('uid', isEqualTo: uid);

    try {
      final data = query.getDocument<Member?>();
      return data;
    } catch (e) {
      debugPrint('readMemberData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete Member Data
  static Future<void> delete(
      {required String meetingId, required String uid}) async {
    final query = FirebaseReference.memberList(meetingId).where('uid', isEqualTo: uid);

    try {
      final snapshot = await query.get();
      final ref = snapshot.docs.first.reference;
      await Future.wait([
        ref.delete(),
        UserMeetingRepository.delete(uid: uid, meetingId: meetingId),
      ]);
    } catch (e) {
      debugPrint('deleteMemberData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen Members Data
  static Stream<List<Member>> listenAllDocuments({required String meetingId}) {
    final ref = FirebaseReference.memberList(meetingId);
    final stream = ref.streamAllDocuments<Member>();

    return stream;
  }

  static Future<Member> fetchMemberNameAndImage(Member member) async {
    final (name, image) = await UserRepository.readOnlyNameAndImage(member.uid);
    final fetchMember = member;
    fetchMember.name = name;
    fetchMember.imageUrl = image;
    return fetchMember;
  }

}
