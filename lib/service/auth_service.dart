import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/models/user.dart';

/// 유저 정보 없을시 바로 로그인 페이지로 이동
class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final _authentication = auth.FirebaseAuth.instance;

  // 로그인 여부  확인
  // FirebaseAuth 유저 정보
  final _authUser = Rx<auth.User?>(null);
  // Firestore 유저 정보
  final _firestoreUser = Rx<User?>(null);
  Rx<User?> get firestoreUser => _firestoreUser;
  
  AuthService(){
    ever(_authUser, _checkAuthUser);
    ever(_firestoreUser, _moveToPage);
    _authUser.bindStream(_authentication.userChanges());
  }

  void _checkAuthUser(auth.User? user) {
    if (user == null) {
      _firestoreUser.value = null;
    } else {
      _firestoreUser.bindStream(_streamFirestoreUser(_authUser.value!.uid));
    }
  }

  void _moveToPage(User? user) {  
    if (_authUser.value == null || user == null) {
      debugPrint('로그인이동');
      if(Get.currentRoute==RoutePages.login) return;
      
      Get.offAllNamed(RoutePages.login);
    } else {
      debugPrint('메인이동');
      if(Get.currentRoute==RoutePages.main) return;

      Get.offAllNamed(RoutePages.main);
    }
  }

  Stream<User?> _streamFirestoreUser(String uid) {
    return UserRepository.stream(uid);
  }


  void logout() {
    GoogleSignIn().signOut();
    _authentication.signOut();
  }
}