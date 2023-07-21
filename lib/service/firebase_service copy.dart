// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:nuduwa_with_flutter/model/chatting.dart';
// import 'package:nuduwa_with_flutter/model/meeting.dart';
// import 'package:nuduwa_with_flutter/model/member.dart';
// import 'package:nuduwa_with_flutter/model/message.dart';
// import 'package:nuduwa_with_flutter/model/user.dart';
// import 'package:nuduwa_with_flutter/model/user_chatting.dart';
// import 'package:nuduwa_with_flutter/model/user_meeting.dart';

// class FirebaseServiceCopy extends GetxService {
//   static FirebaseServiceCopy get instance => Get.find();

//   // 사용자ID
//   String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

//   // listener
//   final _listeners = <dynamic, StreamSubscription>{};

//   // Firebase CRUD
//   /*
//   Firestore - User      - UserMeeting
//                         └ UserChatting
//             └ Meeting   - Member
//                         └ Message
//             └ Chatting  - Message



//   */

//   // Firestore 경로
//   FirebaseFirestore get db => FirebaseFirestore.instance;

//   //
//   //  User
//   //
//   /// User Collection
//   CollectionReference<UserModel> get userList =>
//       db.collection('User').withConverter<UserModel>(
//             fromFirestore: UserModel.fromFirestore,
//             toFirestore: (UserModel user, options) => user.toFirestore(),
//           );

//   /// User/UserMeeting Collection
//   CollectionReference<UserMeeting> userMeetingList(String uid) {
//     return db
//         .collection('User')
//         .doc(uid)
//         .collection('UserMeeting')
//         .withConverter<UserMeeting>(
//           fromFirestore: UserMeeting.fromFirestore,
//           toFirestore: (UserMeeting userMeeting, options) =>
//               userMeeting.toFirestore(),
//         );
//   }

//   /// User/UserChatting Collection
//   CollectionReference<UserChatting> userChattingList(String uid) {
//     return db
//         .collection('User')
//         .doc(uid)
//         .collection('UserChatting')
//         .withConverter<UserChatting>(
//           fromFirestore: UserChatting.fromFirestore,
//           toFirestore: (UserChatting userChatting, options) =>
//               userChatting.toFirestore(),
//         );
//   }



//   //
//   //  Meeting
//   //
//   /// Meeting Collection
//   CollectionReference<Meeting> get meetingList =>
//       db.collection('Meeting').withConverter<Meeting>(
//             fromFirestore: Meeting.fromFirestore,
//             toFirestore: (Meeting meeting, options) => meeting.toFirestore(),
//           );

//   /// Meeting/Member Collection
//   CollectionReference<Member> memberList(String meetingId) {
//     return db
//         .collection('Meeting')
//         .doc(meetingId)
//         .collection('Member')
//         .withConverter<Member>(
//           fromFirestore: Member.fromFirestore,
//           toFirestore: (Member member, options) => member.toFirestore(),
//         );
//   }

//   /// Meeting/Message Collection
//   CollectionReference<Message> meetingMessageList(String meetingId) {
//     return db
//         .collection('Meeting')
//         .doc(meetingId)
//         .collection('Message')
//         .withConverter<Message>(
//           fromFirestore: Message.fromFirestore,
//           toFirestore: (Message message, options) => message.toFirestore(),
//         );
//   }  

//   //
//   //  Chatting
//   //
//   /// Chatting Collection
//   CollectionReference<Chatting> get chattingList =>
//       db.collection('Chatting').withConverter<Chatting>(
//             fromFirestore: Chatting.fromFirestore,
//             toFirestore: (Chatting chatting, options) => chatting.toFirestore(),
//           );

//   /// Chatting/Message Collection
//   CollectionReference<Message> chattingMessageList(String chatttingId) {
//     return db
//         .collection('Chatting')
//         .doc(chatttingId)
//         .collection('Message')
//         .withConverter<Message>(
//           fromFirestore: Message.fromFirestore,
//           toFirestore: (Message message, options) => message.toFirestore(),
//         );
//   }

//   // Listener
//   void addListener(
//       {required dynamic ref, required StreamSubscription listener}) {
//     if (_listeners[ref] == null) {
//       _listeners[ref] = listener;
//     }
//   }

//   void cancelListener({required dynamic ref}) {
//     if (_listeners[ref] != null) {
//       _listeners[ref]?.cancel();
//       _listeners.remove(ref);
//     }
//   }

//   // User
//   Future<void> createUserData(UserModel user) async {
//     final ref = userList.doc(user.id);
//     await ref.set(user);
//   }

//   Future<UserModel?> readUserData(String uid) async {
//     final ref = userList.doc(uid);
//     final snapshot = await ref.get();

//     return snapshot.data();
//   }


//   // UserMeeting
//   Future<void> createUserMeetingData(
//       String meetingId, String hostUid, DateTime meetingTime) async {
//     final userMeeting = UserMeeting(
//         meetingId: meetingId,
//         hostUid: hostUid,
//         isEnd: false,
//         meetingDate: meetingTime);
//     final ref = userMeetingList(currentUid!).doc();
//     await ref.set(userMeeting);
//   }

//   Future<void> deleteUserMeetingData(
//       {required String meetingId, required String uid}) async {
//     final query = userMeetingList(uid).where('meetingId', isEqualTo: meetingId);
//     final snapshot = await query.get();
//     final ref = snapshot.docs.first.reference;
//     await ref.delete();
//   }

//   Future<UserMeeting?> readUserMeetingData(String meetingId, String uid) async {
//     final ref = userMeetingList(uid).where('meetingId', isEqualTo: meetingId);
//     var snapshot = await ref.get();

//     return snapshot.docs.first.data();
//   }

//   // UserChatting
//   Future<void> createUserChattingData({
//       required String chattingId, required String uid, required String otherUid}) async {
//     final userChatting = UserChatting(
//         chattingId: chattingId,
//         otherUid: otherUid,
//         lastReadTime: DateTime.now(),
//         );
//     final ref = userChattingList(uid).doc();
//     await ref.set(userChatting);
//   }

//   Future<UserChatting?> readUserChattingData({required String uid, required String otherUid}) async {
//     final ref = userChattingList(uid).where('otherUid', isEqualTo: otherUid);
//     try{
//     final snapshot = await ref.get();
//     if(snapshot.docs.isEmpty) {
//       return null;
//     }
//     return snapshot.docs.first.data();
//     }catch(e){
//       debugPrint('error: ${e.toString()}');
//       return null;
//     }
//   }

//   // Meeting
//   Future<void> createMeetingData(Meeting meeting) async {
//     debugPrint(meeting.toFirestore().toString());
//     final ref = meetingList;
//     try {
//       final newMeetingRef = await ref.add(meeting);
//       final meetingId = newMeetingRef.id;
//       debugPrint(meetingId);
//       await createMemberData(meetingId, currentUid!, meeting.meetingTime);
//     } catch (e) {
//       debugPrint('에러: ${e.toString()}');
//       // rethrow;
//     }
//   }

//   Future<Meeting?> readMeetingData(String meetingId) async {
//     final ref = meetingList.doc(meetingId);
//     var snapshot = await ref.get();

//     return snapshot.data();
//   }

//   Future<Meeting> fetchHostData(Meeting meeting) async {
//     final host = await readUserData(meeting.hostUid);
//     meeting.hostName = host?.name ?? '이름없음';
//     meeting.hostImageUrl = host?.imageUrl;
//     return meeting;
//   }

//   Future<void> updateMeetingData(
//       {required String meetingId,
//       String? title,
//       String? description,
//       String? place}) async {
//     final ref = meetingList.doc(meetingId);
//     try {
//       await ref.update({
//         if (title != null) "title": title,
//         if (description != null) "description": description,
//         if (place != null) "place": place,
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Meeting tempMeetingData() {
//     return Meeting(
//       title: '',
//       description: '',
//       place: '',
//       maxMembers: 0,
//       category: '',
//       location: const LatLng(0, 0),
//       meetingTime: DateTime(0),
//       hostUid: '',
//     );
//   }

//   // Member
//   Future<void> createMemberData(
//       String meetingId, String hostUid, DateTime meetingTime) async {
//     final member = Member(uid: currentUid!);
//     final ref = memberList(meetingId).doc();
//     try {
//       await Future.wait([
//         ref.set(member),
//         createUserMeetingData(meetingId, hostUid, meetingTime),
//       ]);
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> deleteMemberData(
//       {required String meetingId, required String uid}) async {
//     final query = memberList(meetingId).where('uid', isEqualTo: uid);
//     final snapshot = await query.get();
//     final ref = snapshot.docs.first.reference;
//     await ref.delete();
//   }

//   Future<Member?> readMemberData(String meetingId, String uid) async {
//     final ref = memberList(meetingId).where('uid', isEqualTo: uid);
//     var snapshot = await ref.get();

//     return snapshot.docs.first.data();
//   }

//   Future<Member> fetchMemberData(Member member) async {
//     try {
//       final user = await readUserData(member.uid);
//       member.name = user?.name ?? '이름없음';
//       member.imageUrl = user?.imageUrl;
//       return member;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   //
//   // Meeting.Message
//   //
//   // Message
//   Future<void> createMeetingMessageData(
//       String meetingId, String uid, String text) async {
//     final message = Message(senderUid: uid, text: text);
//     final ref = meetingMessageList(meetingId).doc();
//     debugPrint('createMessageData');
//     try {
//       await ref.set(message);
//     } catch (e) {
//       debugPrint('오류!! createMessageData: ${e.toString()}');
//       rethrow;
//     }
//   }

//   //
//   // Chatting
//   //
//   Future<DocumentReference<Chatting>> createChattingData({required String uid, required String otherUid}) async {
//     final chatting = Chatting(people: [uid, otherUid]);
//     final ref = chattingList.doc();
//     await ref.set(chatting);
//     return ref;
//   }

//   //
//   // Chatting.Message
//   //
//   Future<void> createChattingMessageData(
//       String chattingId, String uid, String text) async {
//     final message = Message(senderUid: uid, text: text);
//     final ref = chattingMessageList(chattingId).doc();
//     debugPrint('createMessageData');
//     try {
//       await ref.set(message);
//     } catch (e) {
//       debugPrint('오류!! createMessageData: ${e.toString()}');
//       rethrow;
//     }
//   }

// }
