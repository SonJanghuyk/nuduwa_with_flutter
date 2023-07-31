import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/circular_reveal_clipper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/profileController/my_profile_controller.dart';
import 'package:nuduwa_with_flutter/service/auth_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class MyProfilePage extends GetView<MyProfileController> {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('ㅇㅇ${Get.arguments}');
    return Scaffold(
      appBar: AppbarOfNuduwa(
        title: '내 정보',
        iconButtons: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              // 검색 아이콘을 눌렀을 때 실행되는 동작
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              AuthService.instance.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 500,
          child: SingleChildScrollView(
            child: Obx(() {
              final user = controller.user.value;
              return Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        foregroundImage: user?.imageUrl != null
                            ? Image.network(user!.imageUrl!).image
                            : Image.asset(Assets.imageNoImage).image,
                        backgroundImage: Image.asset(Assets.imageLoading)
                            .image, // 로딩 중일 때 보여줄 이미지
                      ),
                      const SizedBox(width: 20),
                      Text(user?.name ?? '',
                          style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 20),
                      Text('id: ${user?.email}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const HalfCircleGuage(progress: 0.2, size: 270),
                  Divider(),
                  Divider(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class HalfCircleGuage extends StatelessWidget {
  final double progress;
  final double size;

  const HalfCircleGuage(
      {super.key, required this.progress, required this.size});

  @override
  Widget build(BuildContext context) {
    final fontSize = size / 7;
    return SizedBox(
      width: size,
      height: size*2 / 3,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              painter: HalfCircleGuagePainter(progress),
              child: SizedBox(
                width: size,
                height: size /5,
              ),
            ),
          ),
          Column(
            children: [
              const Spacer(flex: 5),
              Text(
                '${(progress * 10).toString()} / 10',
                style: TextStyle(fontSize: fontSize),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '친절해요',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  Icon(Icons.tag_faces, size: fontSize, color: Colors.amber),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}

class HalfCircleGuagePainter extends CustomPainter {
  final double progress;

  HalfCircleGuagePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width / 20; // 프로그래스 바의 두께를 조정합니다.
    final double radius = size.width / 2;
    final double angle = 3.14 * progress;

    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // 뒷배경 원을 그립니다.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      3.14,
      false,
      backgroundPaint,
    );

    // 프로그래스 바를 그립니다.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(HalfCircleGuagePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
