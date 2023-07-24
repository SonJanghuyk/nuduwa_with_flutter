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

class MemberRepository{
  static final MemberRepository instance = MemberRepository._internal();

  MemberRepository._internal();

  final firebase = FirebaseService.instance;
  
  Future<DocumentReference<Member>?> createMemberData({required String memberUid,required String meetingId, required String hostUid}) async {
    final member = Member(uid: memberUid);
    final ref = firebase.memberList(meetingId).doc();
    try {
      await Future.wait([
        ref.set(member),
        UserMeetingRepository.instance.createUserMeetingData(meetingId, hostUid),
      ]);
      return ref;

    } catch (e) {
      debugPrint('createMemberData에러: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteMemberData(
      {required String meetingId, required String uid}) async {
    final query = firebase.memberList(meetingId).where('uid', isEqualTo: uid);
    
    try{
      final snapshot = await query.get();
      final ref = snapshot.docs.first.reference;
      await ref.delete();

    }catch(e){
      debugPrint('deleteMemberData에러: ${e.toString()}');
      rethrow;
    }     
  }

  Future<Member?> readMemberData(String meetingId, String uid) async {
    final ref = firebase.memberList(meetingId).where('uid', isEqualTo: uid);

    try{
      final snapshot = await ref.get();
      return snapshot.docs.first.data();

    }catch(e){
      debugPrint('readMemberData에러: ${e.toString()}');
      rethrow;
    }   
    
  }

  Future<Member> fetchMemberData(Member member) async {
    try {
      final user = await UserRepository.instance.readUserData(member.uid);
      member.name = user?.name ?? '이름없음';
      member.imageUrl = user?.imageUrl;
      return member;

    } catch (e) {
      debugPrint('fetchMemberData에러: ${e.toString()}');
      rethrow;
    }
  }
}