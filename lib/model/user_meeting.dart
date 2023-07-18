import 'package:cloud_firestore/cloud_firestore.dart';

class UserMeeting {
  final String? id;
  final String meetingId;
  final String hostUid;
  final bool isEnd;
  final List<String>? nonReviewMembers;
  final DateTime meetingDate;

  UserMeeting({
    this.id,
    required this.meetingId,
    required this.hostUid,
    required this.isEnd,
    this.nonReviewMembers,
    required this.meetingDate,
  });

  factory UserMeeting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final meetingId = data?['meetingId'] as String?;
    final hostUid = data?['hostUid'] as String?;
    final isEnd = data?['isEnd'] as bool?;
    final meetingDate = data?['meetingDate'] as Timestamp?;
    if (meetingId == null ||
        hostUid == null ||
        isEnd == null ||
        meetingDate == null) {
      return throw '에러! something is null';
    }

    return UserMeeting(
      id: snapshot.id,
      meetingId: meetingId,
      hostUid: hostUid,
      isEnd: isEnd,
      nonReviewMembers: data?['nonReviewMembers'] as List<String>?,
      meetingDate: meetingDate.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "meetingId": meetingId,
      "hostUid": hostUid,
      "isEnd": isEnd,
      "meetingDate": meetingDate,
    };
  }
}

// class UserMeetingManager extends UserManager {
//   static UserMeetingManager get instance => Get.find();

  
// }
