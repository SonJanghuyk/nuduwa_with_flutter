import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class Chatting {
  final String? id;
  final List<String> people;
  final DateTime? firstChattingTime;

  Chatting({
    this.id,
    required this.people,
    this.firstChattingTime,
  });

  factory Chatting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final firstChattingTime = data?['firstChattingTime'] as Timestamp?;
    if (firstChattingTime == null) {
      return throw '에러! firstChattingTime is null';
    }
    return Chatting(
      id: snapshot.id,
      people: data?['people'] is Iterable ? List.from(data?['people']) : [],
      firstChattingTime: firstChattingTime.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "people": people,
      "firstChattingTime": FieldValue.serverTimestamp(),
    };
  }
}

class ChattingRepository {
  static final ChattingRepository instance = ChattingRepository._internal();

  ChattingRepository._internal();

  final firebase = FirebaseService.instance;

  Future<DocumentReference<Chatting>> createChattingData(
      {required String uid, required String otherUid}) async {
    final chatting = Chatting(people: [uid, otherUid]);
    final ref = firebase.chattingList.doc();

    try {
      await ref.set(chatting);
      return ref;
    } catch (e) {
      debugPrint('createChattingData에러: ${e.toString()}');
      rethrow;
    }
  }
}
