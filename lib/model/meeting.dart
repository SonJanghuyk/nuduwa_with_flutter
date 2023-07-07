import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/firebase_manager.dart';
import 'package:nuduwa_with_flutter/model/user.dart';

class Meeting {
  final String? id;

  final String title;
  final String description;
  final String place;
  final int maxMemers;
  final String category;

  final LatLng location;
  final String? goeHash;

  final DateTime meetingTime;
  final DateTime? publishedTime;

  final String hostUid;
  String? hostName;
  String? hostImage;

  final List<Member> members;

  Meeting({
    this.id,
    required this.title,
    required this.description,
    required this.place,
    required this.maxMemers,
    required this.category,
    required this.location,
    this.goeHash,
    required this.meetingTime,
    this.publishedTime,
    required this.hostUid,
    this.hostName,
    this.hostImage,
    required this.members,
  });

  factory Meeting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final latitude = data?['latitude'];
    final longitude = data?['longitude'];
    final membersData = data?['members'] as List<dynamic>?;
    List<Member> members = [];
    if (membersData != null) {
      members =
          membersData.map((memberData) => Member.fromJson(memberData)).toList();
    }

    return Meeting(
      id: snapshot.id,
      title: data?['title'],
      description: data?['description'],
      place: data?['place'],
      maxMemers: data?['maxMemers'],
      category: data?['category'],
      location: LatLng(latitude, longitude),
      goeHash: data?['goeHash'],
      meetingTime: data?['meetingTime'].toDate(),
      publishedTime: data?['publishedTime'].toDate(),
      hostUid: data?['hostUID'],
      members: members,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "description": description,
      "place": place,
      "maxMemers": maxMemers,
      "category": category,
      "latitude": location.latitude,
      "longitude": location.longitude,
      if (goeHash != null) "goeHash": goeHash,
      "meetingTime": meetingTime,
      "publishedTime": FieldValue.serverTimestamp(),
      "hostUID": hostUid
    };
  }

  // combineHost(UserModel host) {
  //   hostName = host.name;
  //   hostImage = host.image ?? 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png?20200912122019';
  // }
}

class Member {
  final String uid;
  String? name;
  String? image;
  final DateTime? joinTime;

  Member({
    required this.uid,
    this.name,
    this.image,
    this.joinTime,
  });

  factory Member.fromJson(Map<String, dynamic>? data) {
    return Member(
      uid: data?['uid'] as String,
      joinTime: (data?['joinTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "joinTime": FieldValue.serverTimestamp(),
    };
  }

  factory Member.fromUser(UserModel user) {
    return Member(uid: user.id!, name: user.name, image: user.image);
  }

  // combineUser(UserModel user) {
  //   name = user.name;
  //   image = user.image ??
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png?20200912122019';
  // }
}

class MeetingManager extends UserManager {
  static MeetingManager get instance => Get.find();

  Future<void> createMeetingData(Meeting meeting) async {
    final ref = meetingList.doc();
    await ref.set(meeting);
  }

  Future<Meeting?> fetchMeetingData(String meetingId) async {
    final ref = meetingList.doc(meetingId);
    var snapshot = await ref.get();

    return snapshot.data();
  }

  Future<Meeting> fetchHostData(Meeting meeting) async {
    final host = await fetchUser(meeting.hostUid);
    meeting.hostName = host?.name ?? '이름없음';
    meeting.hostImage = host?.image ??
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png?20200912122019';

    return meeting;
  }

  Future<void> joinMeeting(String meetingId) async {
    final member = Member(uid: currentUid!);
    final ref = meetingList.doc(meetingId);
    ref.update({"members" : FieldValue.arrayUnion([member])});
  }

  Future<void> leaveMeeting(String meetingId) async {
    final member = Member(uid: currentUid!);
    final ref = meetingList.doc(meetingId);
    ref.update({"members" : FieldValue.arrayUnion([member])});
  }
}
