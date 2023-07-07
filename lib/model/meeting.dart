import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  final String hostUID;
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
    required this.hostUID,
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
      hostUID: data?['hostUID']
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
      "hostUID": hostUID      
    };
  }
}
