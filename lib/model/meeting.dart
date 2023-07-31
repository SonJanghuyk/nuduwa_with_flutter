import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/model/member.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class Meeting {
  final String? id;

  final String title;
  final String description;
  final String place;
  final int maxMembers;
  final String category;

  final LatLng location;
  final String? goeHash;

  final DateTime meetingTime;
  DateTime publishedTime;

  final String hostUid;
  String? hostName;
  String? hostImageUrl;

  final bool isEnd;

  Meeting({
    this.id,
    required this.title,
    required this.description,
    required this.place,
    required this.maxMembers,
    required this.category,
    required this.location,
    this.goeHash,
    required this.meetingTime,
    DateTime? publishedTime,
    required this.hostUid,
    this.hostName,
    this.hostImageUrl,
    bool? isEnd,
  }) : publishedTime = publishedTime ??
            DateTime.now().toUtc().add(const Duration(hours: 9)),
        isEnd = isEnd ?? false;

  factory Meeting.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final latitude = data?['latitude'];
    final longitude = data?['longitude'];
    if (latitude == null) {
      return throw '에러! some meeting data is null';
    }

    return Meeting(
      id: snapshot.id,
      title: data?['title'],
      description: data?['description'],
      place: data?['place'],
      maxMembers: data?['maxMembers'],
      category: data?['category'],
      location: LatLng(latitude, longitude),
      goeHash: data?['goeHash'],
      meetingTime: data?['meetingTime'].toDate(),
      publishedTime: data?['publishedTime'].toDate(),
      hostUid: data?['hostUID'],
      isEnd: data?['isEnd'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "description": description,
      "place": place,
      "maxMembers": maxMembers,
      "category": category,
      "latitude": location.latitude,
      "longitude": location.longitude,
      if (goeHash != null) "goeHash": goeHash,
      "meetingTime": meetingTime,
      "publishedTime": FieldValue.serverTimestamp(),
      "hostUID": hostUid,
      "isEnd" : isEnd,
    };
  }

  factory Meeting.clone(Meeting meeting) {
    return Meeting(
      id: meeting.id,
      title: meeting.title,
      description: meeting.description,
      place: meeting.place,
      maxMembers: meeting.maxMembers,
      category: meeting.category,
      location: meeting.location,
      goeHash: meeting.goeHash,
      meetingTime: meeting.meetingTime,
      publishedTime: meeting.publishedTime,
      hostUid: meeting.hostUid,
      hostName: meeting.hostName,
      hostImageUrl: meeting.hostImageUrl,
      isEnd: meeting.isEnd,
    );
  }
}

enum MeetingCategory {
  hobby('hobby', '취미활동'),
  meal('meal', '식사'),
  drink('drink', '술자리'),
  exercise('exercise', '운동'),
  date('date', '소개팅'),
  talk('talk', '수다');

  final String category;
  final String displayName;
  const MeetingCategory(this.category, this.displayName);
}

class MeetingRepository{

  /// Create Meeting Data
  static Future<DocumentReference<Meeting>?> create({required Meeting meeting, required String uid}) async {

    final ref = FirebaseReference.meetingList;
    try {
      final newMeetingRef = await ref.add(meeting);
      final meetingId = newMeetingRef.id;
      await MemberRepository.create(memberUid: uid, meetingId: meetingId, hostUid: uid);
      return newMeetingRef;

    } catch (e) {
      debugPrint('createMeetingData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Read Meeting Data
  static Future<Meeting?> read(String meetingId) async {
    final ref = FirebaseReference.meetingList.doc(meetingId);
    try{
      final data = ref.getDocument<Meeting?>();
      return data;

    }catch(e){
      debugPrint('readMeetingData에러: ${e.toString()}');
      rethrow;
    } 
  }  

  /// Update Meeting Data
  static Future<void> update(
      {required String meetingId,
      String? title,
      String? description,
      String? place}) async {
    final ref = FirebaseReference.meetingList.doc(meetingId);
    try {
      await ref.update({
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (place != null) "place": place,
      });

    } catch (e) {
      debugPrint('updateMeetingData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen Meetings Data
  static Stream<Meeting?> listen({required String meetingId}) {
    final ref = FirebaseReference.meetingList.doc(meetingId);
    final stream = ref.listenDocument<Meeting>();

    return stream;
  }

  /// Listen Meetings Data
  static Stream<List<Meeting>> listenAllDocuments() {
    final ref = FirebaseReference.meetingList;
    final stream = ref.listenAllDocuments<Meeting>();

    return stream;
  }

  static Future<Meeting> fetchHostNameAndImage(Meeting meeting) async {
    final (name, image) = await UserRepository.readOnlyNameAndImage(meeting.hostUid);
    final fetchMeeting = meeting;
    fetchMeeting.hostName = name;
    fetchMeeting.hostImageUrl = image;
    return fetchMeeting;
  }

  

  static Meeting tempMeetingData() {
    return Meeting(
      title: '',
      description: '',
      place: '',
      maxMembers: 0,
      category: '',
      location: const LatLng(0, 0),
      meetingTime: DateTime(0),
      hostUid: '',
    );
  }
}
