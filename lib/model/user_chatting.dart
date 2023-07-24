import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

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
      'chattingId': chattingId,
      'otherUid': otherUid,
      'lastReadTime': FieldValue.serverTimestamp(),
    };
  }
}

class UserChattingRepository {
  static final UserChattingRepository instance =
      UserChattingRepository._internal();

  UserChattingRepository._internal();

  final firebase = FirebaseService.instance;

  Future<DocumentReference<UserChatting>> createUserChattingData(
      {required String chattingId,
      required String uid,
      required String otherUid}) async {
    final userChatting = UserChatting(
      chattingId: chattingId,
      otherUid: otherUid,
      lastReadTime: DateTime.now(),
    );
    final ref = firebase.userChattingList(uid).doc();

    try {
      await ref.set(userChatting);
      return ref;

    } catch (e) {
      debugPrint('오류!! createUserChattingData: ${e.toString()}');
      rethrow;
    }
  }

  Future<UserChatting?> readUserChattingData(
      {required String uid, required String otherUid}) async {
    final ref = firebase.userChattingList(uid).where('otherUid', isEqualTo: otherUid);
    try {
      final snapshot = await ref.get();
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return snapshot.docs.first.data();

    } catch (e) {
      debugPrint('오류!! readUserChattingData: ${e.toString()}');
      return null;
    }
  }
}
