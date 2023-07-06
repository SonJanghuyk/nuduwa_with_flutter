import 'package:cloud_firestore/cloud_firestore.dart';

class Meeter {
  final String? id;
  final String? name;
  final String? email;
  final String? image;
  final String? introdution;
  final List<String>? interests;
  final DateTime? signUpTime;

  Meeter({
    this.id, 
    this.name, 
    this.email, 
    this.image, 
    this.introdution, 
    this.interests, 
    this.signUpTime
  });

  factory Meeter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Meeter(
      id: snapshot.id,
      name: data?['name'],
      email: data?['email'],
      image: data?['image'],
      introdution: data?['introdution'],
      interests: data?['interests'],
      signUpTime: data?['signUpTime'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (image != null) "image": image,
      if (introdution != null) "introdution": introdution,
      if (interests != null) "interests": interests,
      "signUpTime": FieldValue.serverTimestamp(),
    };
  }  
}

class MeeterManager {

  static createFirestore(Meeter meeter, Query ref) {
    
  }

}