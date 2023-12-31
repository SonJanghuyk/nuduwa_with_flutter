import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:nuduwa_with_flutter/models/chat_room.dart';
import 'package:nuduwa_with_flutter/models/meeting.dart';
import 'package:nuduwa_with_flutter/models/member.dart';
import 'package:nuduwa_with_flutter/models/message.dart';
import 'package:nuduwa_with_flutter/models/user.dart';
import 'package:nuduwa_with_flutter/models/user_chatting.dart';
import 'package:nuduwa_with_flutter/models/user_meeting.dart';

class FirebaseReference {
  // 사용자ID
  static String? get currentUid => auth.FirebaseAuth.instance.currentUser?.uid;

  // Firebase CRUD
  /*
  Firestore - User      - UserMeeting
                        └ UserChatting
            └ Meeting   - Member
                        └ Message
            └ Chatting  - Message
  */

  // Firestore 경로
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  //
  //  User
  //
  /// User Collection
  static CollectionReference<User> get userList =>
      db.collection('User').withConverter<User>(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, options) => user.toFirestore(),
          );

  /// User/UserMeeting Collection
  static CollectionReference<UserMeeting> userMeetingList(String uid) {
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
  static CollectionReference<UserChatting> userChattingList(String uid) {
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
  static CollectionReference<Meeting> get meetingList =>
      db.collection('Meeting').withConverter<Meeting>(
            fromFirestore: Meeting.fromFirestore,
            toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
          );

  /// Meeting/Member Collection
  static CollectionReference<Member> memberList(String meetingId) {
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
  static CollectionReference<Message> meetingMessageList(String meetingId) {
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
  static CollectionReference<ChatRoom> get chattingList =>
      db.collection('Chatting').withConverter<ChatRoom>(
            fromFirestore: ChatRoom.fromFirestore,
            toFirestore: (ChatRoom chatting, options) => chatting.toFirestore(),
          );

  /// Chatting/Message Collection
  static CollectionReference<Message> chattingMessageList(String chatttingId) {
    return db
        .collection('Chatting')
        .doc(chatttingId)
        .collection('Message')
        .withConverter<Message>(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message message, options) => message.toFirestore(),
        );
  }
}

extension FirestoreQueryExtension on Query {
  /// Get All Items in Query
  Future<List<T>> getAllDocuments<T>() async {
    final snapshots = await get();
    final list = snapshots.docs
        .map((doc) => doc.data() as T)
        .where((data) => data != null)
        .toList();

    //.map((doc) => doc.data() as T).toList();
    return list;
  }

  /// Get First Item in Query
  Future<T?> getDocument<T>() async {
    final snapshots = await get();
    final docs = snapshots.docs
        .map((doc) => doc.data() as T?)
        .where((data) => data != null);

    final data = docs.isEmpty ? null : docs.first;

    return data;
  }

  /// Listen First Items in Query
  Stream<T?> streamDocument<T>() {
    final stream = snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc.data())
        .where((data) => data != null)
        .first as T?);
    return stream;
  }

  /// Listen All Items in Query
  Stream<List<T>> streamAllDocuments<T>() {
    final stream = snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as T)
        .where((data) => data != null)
        .toList());
    return stream;
  }
}

extension FirestoreDocumentReferenceExtension on DocumentReference {
  /// Get Item in DocumentReference
  Future<T?> getDocument<T>() async {
    final snapshots = await get();
    final data = snapshots.data() as T?;
    return data;
  }

  /// Listen Item in DocumentReference
  Stream<T?> streamDocument<T>() {
    final stream = snapshots().map((snapshot) => snapshot.data() as T?);
    return stream;
  }
}
