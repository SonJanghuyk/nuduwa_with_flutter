import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// 유저 정보 없을시 바로 로그인 페이지로 이동
class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  FirebaseAuth authentication = FirebaseAuth.instance;
  late Rx<User?> _user; // user 인증여부 확인(null이면 비회원)
  RxBool isLogin = false.obs;
  
  AuthService(){
    _user = Rx<User?>(authentication.currentUser);
    _user.bindStream(authentication.userChanges());
    ever(_user, _moveToPage);
  }

  _moveToPage(User? user) {    
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
    authentication.signOut();
  }
}