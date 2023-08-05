import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class Message {
  final String? id;
  final String senderUid;
  final String text;
  final DateTime sendTime;

  final bool isSystemMessage;

  Message({
    this.id,
    required this.senderUid,
    required this.text,
    bool? isSystemMessage,
    DateTime? sendTime,
  })  : sendTime = sendTime ?? DateTime.now(),
        isSystemMessage = isSystemMessage ?? false;

  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final sendTime = data?['sendTime'] as Timestamp? ?? Timestamp.fromDate(DateTime.now());
    return Message(
      id: snapshot.id,
      senderUid: data?['senderUid'] as String,  
      text: data?['text'] as String,    
      sendTime: sendTime.toDate(),
      isSystemMessage: data?['isSystemMessage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "senderUid": senderUid,
      "text": text,
      if (isSystemMessage) "isSystemMessage": true,
      "sendTime": FieldValue.serverTimestamp(),
    };
  }
}

class MeetingMessageRepository{

  /// Create MeetingMessage Data
  static Future<DocumentReference<Message>> create(
      {required String meetingId, required String uid, required String text}) async {
    final message = Message(senderUid: uid, text: text);
    final ref = FirebaseReference.meetingMessageList(meetingId).doc();
    try {
      await ref.set(message);
      return ref;

    } catch (e) {
      debugPrint('오류!! createMessageData: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen MeetingMessages Data
  static Stream<List<Message>> streamAllDocuments(String meetingId) {
    final ref = FirebaseReference.meetingMessageList(meetingId);
    final stream = ref.streamAllDocuments<Message>();

    return stream;
  }
}

class ChattingMessageRepository{

  /// Create ChattingMessage Data
  static Future<DocumentReference<Message>> create(
      {required String chattingId, required String uid, required String text}) async {
    final message = Message(senderUid: uid, text: text);
    final ref = FirebaseReference.chattingMessageList(chattingId).doc();
    try {
      await ref.set(message);
      return ref;

    } catch (e) {
      debugPrint('오류!! createMessageData: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen MeetingMessages Data
  static Stream<List<Message>> streamAllDocuments(String chattingId) {
    final ref = FirebaseReference.chattingMessageList(chattingId);
    final stream = ref.streamAllDocuments<Message>();

    return stream;
  }
}