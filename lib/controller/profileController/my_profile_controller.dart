import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/model/chat_room.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/model/user_chatting.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MyProfileController extends GetxController {
  // tag is meetingId
  static MyProfileController get instance => Get.find();

  final user = Rx<User?>(null);

  final formKey = GlobalKey<FormState>();

  final isEdit = RxBool(false);
  final isLoading = RxBool(false);

  final selectedImage = Rx<String?>(null);

  String? editName;
  String? editEmail;
  String? editImageUrl;
  String? editIntrodution;
  List<String>? editInterests;

  @override
  void onInit() {
    super.onInit();
    listenerForUser();
  }

  void listenerForUser() {
    debugPrint('listenerForUser');
    final ref = FirebaseReference.userList.doc(FirebaseReference.currentUid);
    final Stream<User?> stream = ref.streamDocument();
    user.bindStream(stream);
    debugPrint('listenerForUser끝');
  }

  void clickedEditProfile() {
    isEdit.value = true;
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      final uid = auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await UserRepository.update(
          uid: uid,
          name: editName,
          email: editEmail,
          imageUrl: editImageUrl,
          introdution: editIntrodution,
          interests: editInterests);
    } catch (e) {
      debugPrint('에러!!!updateEdit: ${e.toString()}');
    } finally {
      isEdit.value = false;
      isLoading.value = false;
    }
  }

  Future<void> getImage() async {
    final pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      selectedImage.value = pickImage.path;
    } else {
      SnackBarOfNuduwa.warning('이미지 없음', '이미지를 선택하세요');
    }
  }
}
