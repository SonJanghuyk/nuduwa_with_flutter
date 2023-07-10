import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_meeting.dart';

class Member {
  final String? id;
  final String uid;
  final String? name;
  final String? image;
  final DateTime? joinTime;

  Member({
    this.id,
    required this.uid,
    this.name,
    this.image,
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
      image: data?['image'] as String?,
      joinTime: joinTime.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "uid": uid,
      if (name != null) "name": name,
      if (image != null) "image": image,
      "joinTime": FieldValue.serverTimestamp(),
    };
  }
}

// class MemberManager extends UserManager {
//   static MemberManager get instance => Get.find();

// }

