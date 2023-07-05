import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuduwa_with_flutter/model/meeter.dart';
import 'package:nuduwa_with_flutter/screens/login_page.dart';
import 'package:nuduwa_with_flutter/screens/main_page.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  late Rx<User?> _user;
  FirebaseAuth authentication = FirebaseAuth.instance;

  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(authentication.currentUser);
    _user.bindStream(authentication.userChanges());
    ever(_user, _moveToPage);
  }

  _moveToPage(User? user) {
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else {
      Get.offAll(() => MainPage());
    }
  }

  void signInWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user==null) {return;}    
      // final currentUser = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      // if (!currentUser.exists) {
        registerUser(user);
      // }
    }catch (e){
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
    }finally{
      isLoading.value = false;
    }
  }

  void registerUser(User user) async {
    final player = Meeter(name: user.displayName, email: user.email, image: user.photoURL);
    final docRef = FirebaseFirestore.instance.collection('user').withConverter(fromFirestore: Meeter.fromFirestore, toFirestore: (Meeter player, options) => player.toFirestore(),).doc(user.uid);

    await docRef.set(player);
  }

  void logout(){
    authentication.signOut();
  }
  
}
