import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/models/user.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';

class MyProfileController extends GetxController {
  // tag is meetingId
  static MyProfileController get instance => Get.find();

  final user = AuthService.instance.firestoreUser;

  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  final isEdit = RxBool(false);
  final isLoading = RxBool(false);

  final selectedImage = Rx<String?>(null);

  String? editName;
  String? editEmail;
  String? editImageUrl;
  String? editIntrodution;
  final editInterests = RxList<String>();


  void clickedEditProfile() {
    editInterests.value = user.value?.interests ?? [];
    isEdit.value = true;
  }

  Future<void> updateProfile() async {
    if (formKey.currentState == null) return;
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      formKey.currentState!.save();
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
  }

  Future<void> getImage() async {
    final pickImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      selectedImage.value = pickImage.path;
    } else {
      SnackBarOfNuduwa.warning('이미지 없음', '이미지를 선택하세요');
    }
  }

  void addInterest() {
    final newInterest = textController.text;
    if (newInterest == '') return;
    editInterests.add(newInterest);
    debugPrint('editInterests: $editInterests');
    textController.clear();
    FocusScope.of(Get.context!).unfocus();
  }

  void removeInterest(String interest) {
    editInterests.remove(interest);
    debugPrint('editInterests: $editInterests');
  }
}
