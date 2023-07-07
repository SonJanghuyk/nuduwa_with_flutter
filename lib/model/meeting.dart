import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/firebase_manager.dart';

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
      hostUid: data?['hostUID']
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

class MeetingManager extends GetxController with FirebaseManager {
  static MeetingManager get instance => Get.find();

  Future<void> createMeetingData(Meeting meeting) async {
    final ref = meetingList.doc();
    await ref.set(meeting);
  }

  Future<Meeting?> fetchMeeting(String meetingId) async {
    final ref = meetingList.doc(meetingId);
    var snapshot = await ref.get();        

    return snapshot.data();
  }
}