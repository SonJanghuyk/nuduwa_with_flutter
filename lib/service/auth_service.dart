import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 유저 정보 없을시 바로 로그인 페이지로 이동
class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final _authentication = FirebaseAuth.instance;
  late final Rx<User?> _user; // user 인증여부 확인(null이면 비회원)
  final isLogin = RxBool(false);
  
  AuthService(){
    _user = Rx<User?>(_authentication.currentUser);
    _user.bindStream(_authentication.userChanges());
    ever(_user, _moveToPage);
  }

  void _moveToPage(User? user) {    
    if (user == null) {
      debugPrint('로그인이동');
      Get.offAllNamed('/login');
      isLogin.value = false;
    } else {
      debugPrint('메인이동');
      Get.offAllNamed('/main');
      isLogin.value = true;
    }
  }

  void logout() {
    GoogleSignIn().signOut();
    _authentication.signOut();
  }
}