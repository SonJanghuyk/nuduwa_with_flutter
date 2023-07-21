import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? imageUrl;
  
  final String? introdution;
  final List<String>? interests;
  final DateTime? signUpTime;

  final SnsData? googleData;

  UserModel( {
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    this.introdution,
    this.interests,
    this.signUpTime,
    this.googleData,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final interests = data?['interests'] is Iterable
        ? List.from(data?['interests']) as List<String>?
        : null;
    final signUpTime = data?['signUpTime'] as Timestamp?;
    if(signUpTime == null) {return throw '에러! signUpTime is null';}

    return UserModel(
      id: snapshot.id,
      name: data?['name'] as String?,
      email: data?['email'] as String?,
      imageUrl: data?['image'] as String?,
      introdution: data?['introdution'] as String?,
      interests: interests,
      signUpTime: signUpTime.toDate(),
      googleData: SnsData.fromJson(data?['googleData']),
    );
  }
  

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (imageUrl != null) "image": imageUrl,
      if (introdution != null) "introdution": introdution,
      if (interests != null) "interests": interests,
      "signUpTime": FieldValue.serverTimestamp(),
      if (googleData != null) "googleData": googleData!.toJson(),
    };
  }
}

class SnsData {
  final String? snsUID;
  final String? snsName;
  final String? snsEmail;
  final String? snsImage;

  SnsData({
    this.snsUID,
    this.snsName,
    this.snsEmail,
    this.snsImage,
  });

  factory SnsData.fromJson(Map<String, dynamic>? data) {
    return SnsData(
      snsUID: data?['snsUID'] as String?,
      snsName: data?['snsName'] as String?,
      snsEmail: data?['snsEmail'] as String?,
      snsImage: data?['snsImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (snsUID != null) "snsUID": snsUID,
      if (snsName != null) "snsName": snsName,
      if (snsEmail != null) "snsEmail": snsEmail,
      if (snsImage != null) "snsImage": snsImage,
    };
  }
}

class UserRepository{
  static final UserRepository instance = UserRepository._internal();

  UserRepository._internal();

  final firebase = FirebaseService.instance;

  Future<DocumentReference<UserModel>> createUserData(UserModel user) async {
    final ref = firebase.userList.doc(user.id);
    try{
      await ref.set(user);
      return ref;

    }catch(e){
      debugPrint('createUserData에러: ${e.toString()}');
      rethrow;
    }    
    
  }

  Future<UserModel?> readUserData(String uid) async {
    final ref = firebase.userList.doc(uid);    
    try{
      final snapshot = await ref.get();
      return snapshot.data();
      
    }catch(e){
      debugPrint('readUserData에러: ${e.toString()}');
      rethrow;
    }    
  }  

    // Future<Uint8List> downloadUserImageData(String? url) async {
  //   if (url != null) {
  //     final response = await http.get(Uri.parse(url));
  //     return response.bodyBytes;
  //   } else {
  //     final ByteData assetData =
  //         await rootBundle.load('assets/images/nuduwa_logo.png');
  //     return assetData.buffer.asUint8List();
  //   }
  // }

}
