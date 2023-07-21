import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuduwa_with_flutter/model/user.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class LoginController extends GetxController {
  static LoginController instance = Get.find();

  // Firestore에서 user정보 가져오는 Manager
  final userRepository = UserRepository.instance;

  final isGoogleLoginLoading = false.obs; // 서버 로그인중
  final isAppleLoginLoading = false.obs; // 서버 로그인중

  @override
  void onReady() {
    super.onReady();

    // Get.put(AuthService());
  }

  void signInWithGoogle() async {
    if (isGoogleLoginLoading.value) return;
    isGoogleLoginLoading.value = true;
    try {
      late UserCredential userCredential;
      if (kIsWeb) {
        // Create a new provider
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

        // Once signed in, return the UserCredential
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        // Or use signInWithRedirect
        // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
      } else if (Platform.isAndroid || Platform.isIOS) {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        Get.snackbar('에러!!!', '지원하지 않는 플랫폼입니다');
        return;
      }

      final user = userCredential.user;

      if (user == null) {
        return;
      }
      final currentUser = await userRepository.readUserData(user.uid);
      if (currentUser == null) {
        registerUser(user);
      }
    } catch (e) {
      Get.snackbar(
        "에러!!!",
        "구글로그인 오류",
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        titleText: const Text(
          "구글로그인 오류",
          style: TextStyle(color: Colors.white),
        ),
        messageText: Text(
          e.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      );
      debugPrint("에러!! 로그인에러: ${e.toString()}");
    } finally {
      isGoogleLoginLoading.value = false;
    }
  }

  void registerUser(User user) async {
    final providerData = user.providerData[0];
    final googleData = SnsData(
        snsUID: providerData.uid,
        snsName: providerData.displayName,
        snsEmail: providerData.email,
        snsImage: providerData.photoURL);
    final userModel = UserModel(
        id: user.uid,
        name: user.displayName,
        email: user.email,
        imageUrl: user.photoURL,
        googleData: googleData);

    await userRepository.createUserData(userModel);
  }
  
}
