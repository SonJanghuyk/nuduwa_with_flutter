import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/screens/login_screen.dart';
import 'package:nuduwa_with_flutter/screens/map/map_screen.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tapIndex = 0;
  late LatLng currentLatLng;
  late List<Widget> _screens;

  final _authentication = FirebaseAuth.instance;

  // User loggeUser;
  void getCurrentUser() {
    final user = _authentication.currentUser;
  }

  // 위치 권한 체크
  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스 활성화 여부 확인
    if (!isLocationEnabled) {
      // 위치 서비스 활성화 안됨
      return '위치 서비스를 활성화해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    //위치 권한 확인
    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 거절됨
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      // 위치 권한 거절됨 (앱에서 재요청 불가)
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    final currentPosition = await Geolocator.getCurrentPosition();

    currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

    return '위치 권한이 허가 되었습니다.';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String>(
            future: checkPermission(),
            builder: (context, snapshot) {
              // 로딩 상태
              if (!snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // 위치 권한 허가된 상태
              if (snapshot.data == '위치 권한이 허가 되었습니다.') {
                _screens = [
                  MapScreen(currentLatLng: currentLatLng),
                  LoginScreen(),
                ];
                return StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                    if (!snapshot.hasData) {
                      return LoginScreen();
                    }

                    return Scaffold(
                      body: _screens[_tapIndex],
                      bottomNavigationBar: BottomNavigationBar(
                        currentIndex: _tapIndex,
                        onTap: (index) {
                          setState(() {
                            _tapIndex = index;
                          });
                        },
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.map),
                            label: '찾기',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.login),
                            label: '로그인',
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              // 위치 권한 없는 상태
              return Center(
                child: Text(
                  snapshot.data.toString(),
                ),
              );
            }),
      ),
    );
  }
}
