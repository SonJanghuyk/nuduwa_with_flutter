import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';
import 'package:http/http.dart' as http;

class FirebaseService extends GetxService {
  static FirebaseService get instance => Get.find();

  // 사용자ID
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  /*
  Firestore - User      - UserMeeting
                        └
            └ Meeting   - Member

  */

  // Firestore 경로
  FirebaseFirestore get db => FirebaseFirestore.instance;
  // Users Collection
  CollectionReference<UserModel> get userList =>
      db.collection('User').withConverter<UserModel>(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (UserModel user, options) => user.toFirestore(),
          );
          
  // Meetings Collection
  CollectionReference<Meeting> get meetingList =>
      db.collection('Meeting').withConverter<Meeting>(
            fromFirestore: Meeting.fromFirestore,
            toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
          );

  // Meetings.Mebers Collection
  CollectionReference<Member> memberList(String meetingId) {
    return db
        .collection('Meeting')
        .doc(meetingId)
        .collection('Member')
        .withConverter<Member>(
          fromFirestore: Member.fromFirestore,
          toFirestore: (Member member, options) => member.toFirestore(),
        );
  }

  // Users.UserMeeting Collection
  CollectionReference<UserMeeting> userMeetingList(String uid) {
    return db
        .collection('User')
        .doc(uid)
        .collection('UserMeeting')
        .withConverter<UserMeeting>(
          fromFirestore: UserMeeting.fromFirestore,
          toFirestore: (UserMeeting userMeeting, options) => userMeeting.toFirestore(),
        );
  }

  // User
  Future<void> createUserData(UserModel user) async {
    final ref = userList.doc(user.id);
    await ref.set(user);
  }

  Future<UserModel?> readUserData(String uid) async {
    final ref = userList.doc(uid);
    final snapshot = await ref.get();

    return snapshot.data();
  }

  Future<Uint8List> downloadUserImageData(String? url) async {
    if (url != null) {
      final response = await http.get(Uri.parse(url));
      return response.bodyBytes;
    } else {
      final ByteData assetData =
      await rootBundle.load('assets/images/nuduwa_logo.png');
      return assetData.buffer.asUint8List();
    }
  }

  // UserMeeting
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

  Future<UserMeeting?> readUserMeetingData(String meetingId, String uid) async {
    final ref = userMeetingList(uid).where('meetingId', isEqualTo: meetingId);
    var snapshot = await ref.get();

    return snapshot.docs.first.data();
  }

  // Meeting
  Future<void> createMeetingData(Meeting meeting) async {
    final ref = meetingList;
    final newMeetingRef = await ref.add(meeting);
    final meetingId = newMeetingRef.id;
    await createMemberData(meetingId, currentUid!, meeting.meetingTime);
  }

  Future<Meeting?> readMeetingData(String meetingId) async {
    final ref = meetingList.doc(meetingId);
    var snapshot = await ref.get();

    return snapshot.data();
  }

  Future<Meeting> fetchHostData(Meeting meeting) async {
    final host = await readUserData(meeting.hostUid);
    meeting.hostName = host?.name ?? '이름없음';
    meeting.hostImageUrl = host?.imageUrl ??
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png?20200912122019';
    final imageData = await http.get(Uri.parse(meeting.hostImageUrl!));
    meeting.hostImageData = imageData.bodyBytes;
    
    return meeting;
  }

  Meeting tempMeetingData() {
    return Meeting(
      title: '',
      description: '',
      place: '',
      maxMemers: 0,
      category: '',
      location: const LatLng(0, 0),
      meetingTime: DateTime(0),
      hostUid: '',
    );
  }

  // Member
  Future<void> createMemberData(
      String meetingId, String hostUid, DateTime meetingTime) async {
    final member = Member(uid: currentUid!);
    final ref = memberList(meetingId).doc();
    await Future.wait([
      ref.set(member),
      createUserMeetingData(meetingId, hostUid, meetingTime),
    ]);
  }

  Future<void> deleteMemberData(String meetingId, String uid) async {
    final query = memberList(meetingId).where('uid', isEqualTo: uid);
    final snapshot = await query.get();
    final ref = snapshot.docs.first.reference;
    await ref.delete();
  }

  Future<Member?> readMemberData(String meetingId, String uid) async {
    final ref = memberList(meetingId).where('uid', isEqualTo: uid);
    var snapshot = await ref.get();

    return snapshot.docs.first.data();
  }  
}
