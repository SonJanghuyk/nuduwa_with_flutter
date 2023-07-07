import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/user.dart';

mixin FirebaseManager {
  // 사용자ID
  static String? get currentUid=> FirebaseAuth.instance.currentUser?.uid;

  // Firestore 경로
  FirebaseFirestore get db => FirebaseFirestore.instance;
  CollectionReference<UserModel> get userList => db.collection('User').withConverter<UserModel>(
    fromFirestore: UserModel.fromFirestore, 
    toFirestore: (UserModel user, options) => user.toFirestore(),
  );
  CollectionReference<Meeting> get meetingList => db.collection('meeting').withConverter<Meeting>(
    fromFirestore: Meeting.fromFirestore, 
    toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
  );
}