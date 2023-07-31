import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<ProviderUserInfo>? providerData;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.imageUrl,
    this.introdution,
    this.interests,
    this.signUpTime,
    this.providerData,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final signUpTime = data?['signUpTime'] as Timestamp? ?? Timestamp.now();
    final providerDataMap = data?['providerData'] as Iterable?;
    final providerData = providerDataMap?.map((e) => ProviderUserInfo.fromFirestore(e));

    return UserModel(
      id: snapshot.id,
      name: data?['name'] as String?,
      email: data?['email'] as String?,
      imageUrl: data?['image'] as String?,
      introdution: data?['introdution'] as String?,
      interests:
          data?['interests'] is Iterable ? List.from(data?['interests']) : null,
      signUpTime: signUpTime.toDate(),
      providerData: providerData?.toList(),          
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
      if (providerData != null) "providerData": providerData?.map((info) => info.toFirestore),
    };
  }
}

class ProviderUserInfo {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final String? providerId;

  ProviderUserInfo({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.providerId,
  });

  factory ProviderUserInfo.fromUserInfo(
    UserInfo userinfo) {

    return ProviderUserInfo(
      uid: userinfo.uid,
      email: userinfo.email,
      displayName: userinfo.displayName,
      photoURL: userinfo.photoURL,
      phoneNumber: userinfo.phoneNumber,
      providerId: userinfo.providerId,
    );
  }

  factory ProviderUserInfo.fromFirestore(
    Map<String, dynamic> data) {

    return ProviderUserInfo(
      uid: data['uid'] as String?,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      providerId: data['providerId'] as String?,
    );
  }

  Map<String, dynamic> get toFirestore => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoURL': photoURL,
    'phoneNumber': phoneNumber,
    'providerId': providerId,
  };
}

class UserRepository {
  /// Create User Data
  static Future<DocumentReference<UserModel>> create(UserModel user) async {
    final ref = FirebaseReference.userList.doc(user.id);
    try {
      await ref.set(user);
      return ref;
    } catch (e) {
      debugPrint('createUserData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Read User Data
  static Future<UserModel?> read(String uid) async {
    final ref = FirebaseReference.userList.doc(uid);
    try {
      final data = await ref.getDocument<UserModel?>();
      return data;
    } catch (e) {
      debugPrint('readUserData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen User Data
  static Stream<UserModel?> listen(String uid) {
    final ref = FirebaseReference.userList.doc(uid);
    try {
      final stream = ref.listenDocument<UserModel?>();
      return stream;
    } catch (e) {
      debugPrint('readUserData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Fetch User name&image Data
  static Future<(String?, String?)> readOnlyNameAndImage(String uid) async {
    try {
      final user = await UserRepository.read(uid);
      return (user?.name, user?.imageUrl);
    } catch (e) {
      debugPrint('readOnlyNameAndImage에러: ${e.toString()}');
      rethrow;
    }
  }
}
