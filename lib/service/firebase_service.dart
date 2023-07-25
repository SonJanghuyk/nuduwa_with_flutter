import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/chatting.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/message.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
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
                        └ UserChatting
            └ Meeting   - Member
                        └ Message
            └ Chatting  - Message



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

  /// User/UserMeeting Collection
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

  /// User/UserChatting Collection
  CollectionReference<UserChatting> userChattingList(String uid) {
    return db
        .collection('User')
        .doc(uid)
        .collection('UserChatting')
        .withConverter<UserChatting>(
          fromFirestore: UserChatting.fromFirestore,
          toFirestore: (UserChatting userChatting, options) =>
              userChatting.toFirestore(),
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

  /// Meeting/Member Collection
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

  /// Meeting/Message Collection
  CollectionReference<Message> meetingMessageList(String meetingId) {
    return db
        .collection('Meeting')
        .doc(meetingId)
        .collection('Message')
        .withConverter<Message>(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toFirestore(),
        );
  }  

  //
  //  Chatting
  //
  /// Chatting Collection
  CollectionReference<Chatting> get chattingList =>
      db.collection('Chatting').withConverter<Chatting>(
            fromFirestore: Chatting.fromFirestore,
            toFirestore: (Chatting chatting, options) => chatting.toFirestore(),
          );

  /// Chatting/Message Collection
  CollectionReference<Message> chattingMessageList(String chatttingId) {
    return db
        .collection('Chatting')
        .doc(chatttingId)
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

}
