import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/user.dart';

class FirebaseManager extends GetxController {
  // 사용자ID
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // Firestore 경로
  FirebaseFirestore get db => FirebaseFirestore.instance;
  CollectionReference<UserModel> get userList =>
      db.collection('User').withConverter<UserModel>(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (UserModel user, options) => user.toFirestore(),
          );
  CollectionReference<Meeting> get meetingList =>
      db.collection('Meeting').withConverter<Meeting>(
            fromFirestore: Meeting.fromFirestore,
            toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
          );
  // CollectionReference<Member> memberList(String meetingId) {
  //   return db
  //       .collection('Meeting')
  //       .doc(meetingId)
  //       .collection('Member')
  //       .withConverter<Member>(
  //         fromFirestore: Member.fromFirestore,
  //         toFirestore: (Member member, options) => member.toFirestore(),
  //       );
  // }
}
