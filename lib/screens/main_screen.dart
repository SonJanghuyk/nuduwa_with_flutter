import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nuduwa_with_flutter/screens/login_screen.dart';
import 'package:nuduwa_with_flutter/screens/map/map_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final _authentication = FirebaseAuth.instance;
  // User loggeUser;
  
  void getCurrentUser(){
    final user = _authentication.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          /*
          if (!snapshot.hasData) {
            return LoginScreen();
          } 
            */
          return Center(
            child: MapScreen(),
          );
        },
      ),
    );
  }
}