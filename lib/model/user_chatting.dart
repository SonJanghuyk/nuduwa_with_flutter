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
    var lastReadTime = data?['lastReadTime'];
    if (lastReadTime is FieldValue) {
      lastReadTime = Timestamp.now();
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

  /// Create UserChatting Data
  static Future<DocumentReference<UserChatting>> create(
      {required String chattingId,
      required String uid,
      required String otherUid}) async {
    final userChatting = UserChatting(
      chattingId: chattingId,
      otherUid: otherUid,
      lastReadTime: DateTime.now(),
    );
    final ref = FirebaseReference.userChattingList(uid).doc();

    try {
      await ref.set(userChatting);
      return ref;
    } catch (e) {
      debugPrint('오류!! createUserChattingData: ${e.toString()}');
      rethrow;
    }
  }

  /// Read UserChatting Data
  static Future<UserChatting?> read(
      {required String uid, required String otherUid}) async {
    final query =
        FirebaseReference.userChattingList(uid).where('otherUid', isEqualTo: otherUid);
    try {
      final data = await query.getDocument<UserChatting?>();
      return data;
    } catch (e) {
      debugPrint('오류!! readUserChattingData: ${e.toString()}');
      rethrow;
    }
  }

  /// Update UserChatting Data
  static Future<void> updateLastReadTime(
      {required String uid, required String userChattingId}) async {
    final ref =
        FirebaseReference.userChattingList(uid).doc(userChattingId);
    try {
      await ref.update({'lastReadTime': DateTime.now()});
    } catch (e) {
      debugPrint('오류!! updateLastReadTimeData: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen User Data
  static Stream<List<UserChatting>> listen(String uid) {
    final ref = FirebaseReference.userChattingList(uid);
    try{
      final stream = ref.streamAllDocuments<UserChatting>();
      return stream;

    }catch(e){
      debugPrint('readUserData에러: ${e.toString()}');
      rethrow;
    }    
  }
}
