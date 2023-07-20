import 'package:cloud_firestore/cloud_firestore.dart';

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