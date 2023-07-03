import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String? id;

  final String title;
  final String description;
  final String place;
  final int maxMemers;

  final Location location;
  final String? goeHash;

  final DateTime meetingTime;
  final DateTime? publishedTime;

  final String hostUID;
  final String? hostName;
  final String? hostImage;

  Meeting({
    this.id, 
    required this.title, 
    required this.description, 
    required this.place, 
    required this.maxMemers,
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
      location: Location(latitude: latitude, longitude: longitude),
      goeHash: data?['goeHash'],
      meetingTime: data?['meetingTime'],
      publishedTime: data?['publishedTime'],
      hostUID: data?['hostUID']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "description": description,
      "place": place,
      "maxMemers": maxMemers,
      "latitude": location.latitude,
      "longitude": location.longitude,
      if (goeHash != null) "goeHash": goeHash,
      "meetingTime": meetingTime,
      "publishedTime": FieldValue.serverTimestamp(),
      "hostUID": hostUID      
    };
  }
}
class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude, 
    required this.longitude,
  });
}