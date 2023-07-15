import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String? id;
  final String uid;
  String? name;
  String? imageUrl;
  final DateTime? joinTime;

  Member({
    this.id,
    required this.uid,
    this.name,
    this.imageUrl,
    this.joinTime,
  });

  factory Member.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final joinTime = data?['joinTime'] as Timestamp?;
    if (joinTime == null) {
      return throw '에러! joinTime is null';
    }
    return Member(
      id: snapshot.id,
      uid: data?['uid'] as String,
      name: data?['name'] as String?,
      imageUrl: data?['image'] as String?,
      joinTime: joinTime.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      if (name != null) "name": name,
      if (imageUrl != null) "image": imageUrl,
      "joinTime": FieldValue.serverTimestamp(),
    };
  }

  factory Member.clone(Member member) {
    return Member(
      id: member.id,
      uid: member.uid,
      name: member.name,
      imageUrl: member.imageUrl,
      joinTime: member.joinTime,
    );
  }
}

// class MemberManager extends UserManager {
//   static MemberManager get instance => Get.find();

// }

