import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

mixin FirebaseManager {
  static String? get currentUID=> FirebaseAuth.instance.currentUser?.uid;

  FirebaseFirestore get db => FirebaseFirestore.instance;
  CollectionReference get userList => db.collection('User');
}