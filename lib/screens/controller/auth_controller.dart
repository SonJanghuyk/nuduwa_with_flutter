import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuduwa_with_flutter/model/player.dart';
import 'package:nuduwa_with_flutter/screens/login_screen.dart';
import 'package:nuduwa_with_flutter/screens/main_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  FirebaseAuth authentication = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(authentication.currentUser);
    _user.bindStream(authentication.userChanges());
    ever(_user, _moveToPage);
  }

  _moveToPage(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => MainScreen());
    }
  }

  void signInWithGoogle() async {
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
      final currentUser = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      if (!currentUser.exists) {
        registerUser(user);
      }
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
    }
  }

  void registerUser(User user) async {
    final player = Player(name: user.displayName, email: user.email, image: user.photoURL);
    final docRef = FirebaseFirestore.instance.collection('user').withConverter(fromFirestore: Player.fromFirestore, toFirestore: (Player player, options) => player.toFirestore(),).doc(user.uid);

    await docRef.set(player);
  }

  void logout(){
    authentication.signOut();
  }
  
}
