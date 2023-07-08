import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final controller = AuthController.instance;

  LoginPage({super.key});

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
                    isLoading: controller.isAppleLoginLoading,
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
                    onPressed: controller.signInWithGoogle,
                    isLoading: controller.isGoogleLoginLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SnsLoginButton extends StatelessWidget {
  final controller = AuthController.instance;

  final String sns;
  final VoidCallback? onPressed;
  final RxBool isLoading;

  SnsLoginButton({
    super.key,
    required this.sns,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading.value ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        fixedSize: MaterialStateProperty.all<Size>(const Size(200, 80)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      child: Obx(
        () => isLoading.value
            ? const CircularProgressIndicator()
            : Row(
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
      ),
    );
  }
}
