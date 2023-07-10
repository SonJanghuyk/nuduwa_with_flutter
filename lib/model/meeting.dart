import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:http/http.dart' as http;

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
  String? hostImageUrl;
  Uint8List? hostImageData; // imageUrl 웹이미지 가져와서 저장하는 변수

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
    this.hostImageUrl,
    this.hostImageData,
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

// class MeetingManager extends UserManager {
//   static MeetingManager get instance => Get.find();

  

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
// }
