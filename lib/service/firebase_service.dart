import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/message.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';

class FirebaseService extends GetxService {
  static FirebaseService get instance => Get.find();

  // 사용자ID
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // listener
  final _listeners = <dynamic, StreamSubscription>{};

  // Firebase CRUD
  /*
  Firestore - User      - UserMeeting
                        └
            └ Meeting   - Member

  */

  // Firestore 경로
  FirebaseFirestore get db => FirebaseFirestore.instance;

  //
  //  User
  //
  /// User Collection
  CollectionReference<UserModel> get userList =>
      db.collection('User').withConverter<UserModel>(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (UserModel user, options) => user.toFirestore(),
          );

  /// User.UserMeeting Collection
  CollectionReference<UserMeeting> userMeetingList(String uid) {
    return db
        .collection('User')
        .doc(uid)
        .collection('UserMeeting')
        .withConverter<UserMeeting>(
          fromFirestore: UserMeeting.fromFirestore,
          toFirestore: (UserMeeting userMeeting, options) =>
              userMeeting.toFirestore(),
        );
  }

  //
  //  Meeting
  //
  /// Meeting Collection
  CollectionReference<Meeting> get meetingList =>
      db.collection('Meeting').withConverter<Meeting>(
            fromFirestore: Meeting.fromFirestore,
            toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
          );

  /// Meeting.Member Collection
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

  /// Meeting.Message Collection
  CollectionReference<Message> messageList(String meetingId) {
    return db
        .collection('Meeting')
        .doc(meetingId)
        .collection('Message')
        .withConverter<Message>(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toFirestore(),
        );
  }

  // Listener
  void addListener(
      {required dynamic ref, required StreamSubscription listener}) {
    if (_listeners[ref] == null) {
      _listeners[ref] = listener;
    }
  }

  void cancelListener({required dynamic ref}) {
    if (_listeners[ref] != null) {
      _listeners[ref]?.cancel();
      _listeners.remove(ref);
    }
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

  // Future<Uint8List> downloadUserImageData(String? url) async {
  //   if (url != null) {
  //     final response = await http.get(Uri.parse(url));
  //     return response.bodyBytes;
  //   } else {
  //     final ByteData assetData =
  //         await rootBundle.load('assets/images/nuduwa_logo.png');
  //     return assetData.buffer.asUint8List();
  //   }
  // }

  // UserMeeting
  Future<void> createUserMeetingData(
      String meetingId, String hostUid, DateTime meetingTime) async {
    final userMeeting = UserMeeting(
        meetingId: meetingId,
        hostUid: hostUid,
        isEnd: false,
        meetingDate: meetingTime);
    final ref = userMeetingList(currentUid!).doc();
    await ref.set(userMeeting);
  }

  Future<void> deleteUserMeetingData(
      {required String meetingId, required String uid}) async {
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
    debugPrint(meeting.toFirestore().toString());
    final ref = meetingList;
    try {
      final newMeetingRef = await ref.add(meeting);
      final meetingId = newMeetingRef.id;
      debugPrint(meetingId);
      await createMemberData(meetingId, currentUid!, meeting.meetingTime);
    } catch (e) {
      debugPrint('에러: ${e.toString()}');
      // rethrow;
    }
  }

  Future<Meeting?> readMeetingData(String meetingId) async {
    final ref = meetingList.doc(meetingId);
    var snapshot = await ref.get();

    return snapshot.data();
  }

  Future<Meeting> fetchHostData(Meeting meeting) async {
    final host = await readUserData(meeting.hostUid);
    meeting.hostName = host?.name ?? '이름없음';
    meeting.hostImageUrl = host?.imageUrl;
    return meeting;
  }

  Future<void> updateMeetingData(
      {required String meetingId,
      String? title,
      String? description,
      String? place}) async {
    final ref = meetingList.doc(meetingId);
    try {
      await ref.update({
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (place != null) "place": place,
      });
    } catch (e) {
      rethrow;
    }
  }

  Meeting tempMeetingData() {
    return Meeting(
      title: '',
      description: '',
      place: '',
      maxMembers: 0,
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
    try {
      await Future.wait([
        ref.set(member),
        createUserMeetingData(meetingId, hostUid, meetingTime),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMemberData(
      {required String meetingId, required String uid}) async {
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

  Future<Member> fetchMemberData(Member member) async {
    try {
      final user = await readUserData(member.uid);
      member.name = user?.name ?? '이름없음';
      member.imageUrl = user?.imageUrl;
      return member;
    } catch (e) {
      rethrow;
    }
  }

  //
  // Meeting.Message
  //
  // Message
  Future<void> createMessageData(
      String meetingId, String uid, String text) async {
    final message = Message(senderUid: uid, text: text);
    final ref = messageList(meetingId).doc();
    debugPrint('createMessageData');
    try {
      await ref.set(message);
    } catch (e) {
      debugPrint('오류!! createMessageData: ${e.toString()}');
      rethrow;
    }
  }
}
