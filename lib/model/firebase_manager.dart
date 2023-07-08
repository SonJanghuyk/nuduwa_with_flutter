import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';

class FirebaseManager extends GetxController {
  // 사용자ID
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Firestore 경로
  FirebaseFirestore get db => FirebaseFirestore.instance;
  // Users Collection
  CollectionReference<UserModel> get userList =>
      db.collection('Users').withConverter<UserModel>(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (UserModel user, options) => user.toFirestore(),
          );
          
  // Meetings Collection
  CollectionReference<Meeting> get meetingList =>
      db.collection('Meetings').withConverter<Meeting>(
            fromFirestore: Meeting.fromFirestore,
            toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
          );

  // Meetings.Mebers Collection
  CollectionReference<Member> memberList(String meetingId) {
    return db
        .collection('Meetings')
        .doc(meetingId)
        .collection('Members')
        .withConverter<Member>(
          fromFirestore: Member.fromFirestore,
          toFirestore: (Member member, options) => member.toFirestore(),
        );
  }

  // Users.UserMeeting Collection
  CollectionReference<UserMeeting> userMeetingList(String uid) {
    return db
        .collection('Users')
        .doc(uid)
        .collection('UserMeeting')
        .withConverter<UserMeeting>(
          fromFirestore: UserMeeting.fromFirestore,
          toFirestore: (UserMeeting userMeeting, options) => userMeeting.toFirestore(),
        );
  }
}
