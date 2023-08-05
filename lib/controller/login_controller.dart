import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/model/user.dart' as usermodel;

class LoginController extends GetxController {
  static LoginController instance = Get.find();

  final isGoogleLoginLoading = false.obs; // 서버 로그인중
  final isAppleLoginLoading = false.obs; // 서버 로그인중

  void signInWithGoogle() async {
    if (isGoogleLoginLoading.value || isAppleLoginLoading.value) return;
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
        SnackBarOfNuduwa.error('에러!!!', '지원하지 않는 플랫폼입니다');
        return;
      }

      final user = userCredential.user;

      if (user == null) return;

      final currentUser = await usermodel.UserRepository.read(user.uid);
      if (currentUser == null) {
        await _registerUser(user);
      }
    } catch (e) {
      SnackBarOfNuduwa.error('에러!!!', '구글로그인 오류');
      debugPrint("에러!! 로그인에러: ${e.toString()}");
    } finally {
      isGoogleLoginLoading.value = false;
    }
  }

  Future<void> _registerUser(User user) async {
    final providerData = user.providerData
        .map((e) => usermodel.ProviderUserInfo.fromUserInfo(e))
        .toList();

    await usermodel.UserRepository.create(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      imageUrl: user.photoURL,
      providerData: providerData,
    );
  }
}
