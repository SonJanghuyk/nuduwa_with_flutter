import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
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
  });

  factory Meeting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final latitude = data?['latitude'];
    final longitude = data?['longitude'];
    if(latitude == null) {return throw '에러! some meeting data is null';}
    

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
}

class MeetingManager extends UserManager {
  static MeetingManager get instance => Get.find();

  Future<void> createMeetingData(Meeting meeting) async {
    final ref = meetingList;
    final newMeetingRef = await ref.add(meeting);
    final meetingId = newMeetingRef.id;
    await MemberManager.instance.createMemberData(meetingId, currentUid!, meeting.meetingTime);
  }

  Future<Meeting?> readMeetingData(String meetingId) async {
    final ref = meetingList.doc(meetingId);
    var snapshot = await ref.get();

    return snapshot.data();
  }

  Future<Meeting> fetchHostData(Meeting meeting) async {
    final host = await readUserData(meeting.hostUid);
    meeting.hostName = host?.name ?? '이름없음';
    meeting.hostImage = host?.image ??
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/330px-No-Image-Placeholder.svg.png?20200912122019';

    return meeting;
  }

  Meeting tempMeetingData() {
    return Meeting(
      title: '',
      description: '',
      place: '',
      maxMemers: 0,
      category: '',
      location: const LatLng(0, 0),
      meetingTime: DateTime(0),
      hostUid: '',
    );
  }

/*
  Future<RxList<Meeting?>> listenerForMeetings() async {
    final meetings = RxList<Meeting?>();
    final ref = meetingList;
    final completer = Completer<RxList<Meeting?>>();

    ref.snapshots().listen((snapshot) {
      meetings.value = snapshot.docs.map((doc) => doc.data()).toList();
      if (!completer.isCompleted) {
        completer.complete(meetings);
      }
    });
    await completer.future;

    return meetings;
  }
*/
}
