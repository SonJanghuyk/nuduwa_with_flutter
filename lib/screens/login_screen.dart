import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/config/palette.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginScreen = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Palette.backgroundColor,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Image(
            image: AssetImage('assets/images/nuduwa_logo.png'),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          Text(
            '너두와에 어서와!',
            style: TextStyle(
              letterSpacing: 1.0,
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '계속하려면 로그인',
            style: TextStyle(
              letterSpacing: 1.0,
              fontSize: 25,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // 버튼이 클릭되었을 때 수행할 작업
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('assets/images/google.png'),
                  // width: 200,
                  // height: 200,
                  // fit: BoxFit.cover,
                ),
                SizedBox(width: 8),
                Text('Google 간편로그인'), 
              ],
            ),
          )
        ],
      ),
    );
  }
}