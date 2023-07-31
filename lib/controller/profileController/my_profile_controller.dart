import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/chatting.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MyProfileController extends GetxController {
  // tag is meetingId
  static MyProfileController get instance => Get.find();

  final user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    listenerForUser();
  }

  void listenerForUser() {
    debugPrint('listenerForUser');
    final ref = FirebaseReference.userList.doc(FirebaseReference.currentUid);
    final Stream<UserModel?> stream = ref.listenDocument();
    user.bindStream(stream);
    debugPrint('listenerForUser끝');
  }
}
