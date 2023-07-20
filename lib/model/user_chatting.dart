import 'package:cloud_firestore/cloud_firestore.dart';

class UserChatting {
  final String? id;
  final String chattingId;
  final String otherUid;
  final DateTime lastReadTime;

  UserChatting({
    this.id,
    required this.chattingId,
    required this.otherUid,
    required this.lastReadTime,
  });

  factory UserChatting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final lastReadTime = data?['lastReadTime'] as Timestamp?;
    if (lastReadTime == null) {
      return throw '에러! lastReadTime is null';
    }

    return UserChatting(
      id: snapshot.id,
      chattingId: data?['chattingId'] as String,
      otherUid: data?['otherUid'] as String,
      lastReadTime: lastReadTime.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chattingRef' : chattingId,
      'otherUid' : otherUid,
      'firstChattingTime' : FieldValue.serverTimestamp(),
    };
  }
}