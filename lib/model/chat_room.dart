import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class ChatRoom {
  final String? id;
  final List<String> people;
  final DateTime? firstChatTime;

  ChatRoom({
    this.id,
    required this.people,
    this.firstChatTime,
  });

  factory ChatRoom.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final people = data?['people'] as Iterable<String>?;
    if(people==null) throw 'null';
    
    return ChatRoom(
      id: snapshot.id,
      people: List.from(people),
      firstChatTime: (data?['firstChatTime'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "people": people,
      "firstChatTime": FieldValue.serverTimestamp(),
    };
  }
}

class ChattingRepository {

  /// Create Chatting Data
  static Future<DocumentReference<ChatRoom>> create(
      {required String uid, required String otherUid}) async {
    final chatting = ChatRoom(people: [uid, otherUid]);
    final ref = FirebaseReference.chattingList.doc();

    try {
      await ref.set(chatting);
      return ref;
    } catch (e) {
      debugPrint('createChattingData에러: ${e.toString()}');
      rethrow;
    }
  }
}
