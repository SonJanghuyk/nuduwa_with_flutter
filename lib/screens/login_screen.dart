import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nuduwa_with_flutter/model/player.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  bool isLoginScreen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
            
                  // 로고
                  Image.asset(
                    'assets/images/nuduwa_logo.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
            
                  const SizedBox(height: 30),

                  // 인삿말1
                  const Text(
                    '너두와에 어서와!',
                    style: TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
                  // 인삿말2
                  const Text(
                    '계속하려면 로그인',
                    style: TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 30,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 300),
                ],
              ),
            ),

            // 버튼들
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // 애플로그인 버튼
                  SnsLoginButton(
                    sns: 'Apple',
                    onPressed: () {},
                  ),
                  
                  const SizedBox(height: 10),
                  const Text(
                    '또는',
                    style: TextStyle(
                      letterSpacing: 1.0,
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 구글로그인 버튼
                  SnsLoginButton(
                    sns: 'Google',
                    onPressed: () {signInWithGoogle();},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
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
  }

  Future<void> registerUser(User user) async {
    final player = Player(name: user.displayName, email: user.email, image: user.photoURL);
    final docRef = FirebaseFirestore.instance.collection('user').withConverter(fromFirestore: Player.fromFirestore, toFirestore: (Player player, options) => player.toFirestore(),).doc(user.uid);
    await docRef.set(player);
  }
}

class SnsLoginButton extends StatelessWidget {
  final String sns;
  final VoidCallback? onPressed;

  const SnsLoginButton({
    super.key,
    required this.sns,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        fixedSize: MaterialStateProperty.all<Size>(const Size(200, 80)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            sns == 'Google'
                ? 'assets/images/google.png'
                : 'assets/images/apple.png',
            color: Colors.white,
            width: 45,
            height: 45,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 8),
          Text('$sns 간편로그인'),
        ],
      ),
    );
  }
}
