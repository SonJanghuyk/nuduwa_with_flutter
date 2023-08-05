import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? imageUrl;

  final String? introdution;
  final List<String>? interests;
  final DateTime? signUpTime;

  List<ProviderUserInfo>? providerData;

  User({
    required this.id,
    required this.name,
    this.email,
    this.imageUrl,
    this.introdution,
    this.interests,
    this.signUpTime,
    this.providerData,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    final signUpTime = data?['signUpTime'] as Timestamp? ?? Timestamp.now();
    final providerDataMap = data?['providerData'] as Iterable?;
    final providerData =
        providerDataMap?.map((e) => ProviderUserInfo.fromFirestore(e));

    return User(
      id: snapshot.id,
      name: data?['name'] as String,
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
      'name': name,
      if (email != null) 'email': email,
      if (imageUrl != null) 'image': imageUrl,
      if (introdution != null) 'introdution': introdution,
      if (interests != null) 'interests': interests,
      "signUpTime": FieldValue.serverTimestamp(),
      if (providerData != null)
        "providerData": providerData?.map((info) => info.toFirestore),
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

  factory ProviderUserInfo.fromUserInfo(UserInfo userinfo) {
    return ProviderUserInfo(
      uid: userinfo.uid,
      email: userinfo.email,
      displayName: userinfo.displayName,
      photoURL: userinfo.photoURL,
      phoneNumber: userinfo.phoneNumber,
      providerId: userinfo.providerId,
    );
  }

  factory ProviderUserInfo.fromFirestore(Map<String, dynamic> data) {
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
  static Future<DocumentReference<User>> create({
    required String id,
    required String? name,
    String? email,
    String? imageUrl,
    List<ProviderUserInfo>? providerData,
  }) async {
    final ref = FirebaseReference.userList.doc(id);
    final newUser = User(
      id: id,
      name: name,
      email: email,
      imageUrl: imageUrl,
      providerData: providerData,
    );
    try {
      await ref.set(newUser);
      return ref;
    } catch (e) {
      debugPrint('createUserData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Read User Basic Data
  static Future<User?> read(String uid) async {
    final ref = FirebaseReference.userList.doc(uid);
    try {
      final data = await ref.getDocument<User?>();
      data?.providerData = null;
      return data;
    } catch (e) {
      debugPrint('readUserData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Read User All Data
  static Future<User?> readAll(String uid) async {
    final ref = FirebaseReference.userList.doc(uid);
    try {
      final data = await ref.getDocument<User?>();
      return data;
    } catch (e) {
      debugPrint('readUserAllData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Update User Data
  static Future<void> update({
    required String uid,
    String? name,
    String? email,
    String? imageUrl,
    String? introdution,
    List<String>? interests,
  }) async {
    final ref = FirebaseReference.userList.doc(uid);
    try {
      await ref.update({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (imageUrl != null) 'image': imageUrl,
        if (introdution != null) 'introdution': introdution,
        if (interests != null) 'interests': interests,
      });
    } catch (e) {
      debugPrint('createUserData에러: ${e.toString()}');
      rethrow;
    }
  }

  /// Listen User Data
  static Stream<User?> stream(String uid) {
    final ref = FirebaseReference.userList.doc(uid);
    try {
      final stream = ref.streamDocument<User?>();
      return stream;
    } catch (e) {
      debugPrint('ListenUserData에러: ${e.toString()}');
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
