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
    final sendTime = data?['sendTime'] as Timestamp?;
    if (sendTime == null) {
      return throw '에러! joinTime is null';
    }
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
  static final MeetingMessageRepository instance = MeetingMessageRepository._internal();

  MeetingMessageRepository._internal();

  final firebase = FirebaseService.instance;

  Future<DocumentReference<Message>> createMeetingMessageData(
      String meetingId, String uid, String text) async {
    final message = Message(senderUid: uid, text: text);
    final ref = firebase.meetingMessageList(meetingId).doc();
    try {
      await ref.set(message);
      return ref;

    } catch (e) {
      debugPrint('오류!! createMessageData: ${e.toString()}');
      rethrow;
    }
  }
}

class ChattingMessageRepository{
  static final ChattingMessageRepository instance = ChattingMessageRepository._internal();

  ChattingMessageRepository._internal();

  final firebase = FirebaseService.instance;

  Future<DocumentReference<Message>> createChattingMessageData(
      String chattingId, String uid, String text) async {
    final message = Message(senderUid: uid, text: text);
    final ref = firebase.chattingMessageList(chattingId).doc();
    try {
      await ref.set(message);
      return ref;

    } catch (e) {
      debugPrint('오류!! createMessageData: ${e.toString()}');
      rethrow;
    }
  }
}