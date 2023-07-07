// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:nuduwa_with_flutter/model/firebase_manager.dart';

// class Member {
//   final String? id;
//   final String uid;
//   final String? name;
//   final String? image;
//   final DateTime? joinTime;

//   Member({
//     this.id,
//     required this.uid,
//     this.name,
//     this.image,
//     this.joinTime,
//   });

//   factory Member.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> snapshot, [
//     SnapshotOptions? options,
//   ]) {
//     final data = snapshot.data();
//     return Member(
//         id: snapshot.id,
//         uid: data?['uid'] as String,
//         name: data?['name'] as String?,        
//         image: data?['image'] as String?,
//         joinTime: (data?['joinTime'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       "uid": uid,
//       if (name != null) "name": name,      
//       if (image != null) "image": image,
//       "joinTime": FieldValue.serverTimestamp(),
//     };
//   }
// }

// class MemberManager extends GetxController with FirebaseManager {
//   static MemberManager get instance => Get.find();

//   Future<void> createMemberData(String meetingId, Member member) async {
//     final ref = memberList(meetingId).doc();
//     await ref.set(member);
//   }

//   Future<Member?> fetchMember(String meetingId, String uid) async {
//     final ref = memberList(meetingId).where('uid', isEqualTo: uid);
//     var snapshot = await ref.get();        

//     return snapshot.docs.first.data();
//   }
// }
