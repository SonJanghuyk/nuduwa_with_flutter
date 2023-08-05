import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        actions: [
          Obx(() {
            final isLoading = controller.isLoading.value;
            final isEdit = controller.isEdit.value;
            if (!isLoading) {
              if (!isEdit) {
                return PopupMenuButton(
                  itemBuilder: (BuildContext context) => [
                    menuItem(
                      text: '프로필 편집',
                      icon: Icons.edit_document,
                      color: Colors.black,
                      ontap: controller.clickedEditProfile,
                    ),
                    menuItem(
                      text: '로그아웃',
                      icon: Icons.logout,
                      color: Colors.black,
                      ontap: AuthService.instance.logout,
                    ),
                  ],
                );
              } else {
                return TextButton(
                    onPressed: controller.updateProfile,
                    child: const Text('수정완료'));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Obx(() {
                final user = controller.user.value;
                final isEdit = controller.isEdit.value;
                final selectedImage = controller.selectedImage.value;
                return Column(
                  children: [
                    // 유저 정보
                    Row(
                      children: [
                        imageCircle(user?.imageUrl,
                            isEdit: isEdit, selectedImage: selectedImage),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            nameText(
                              user?.name ?? '',
                              isEdit: isEdit,
                              onSaved: ((newValue) =>
                                  // 원래 값이랑 똑같은때 null
                                  controller.editName =
                                      newValue != user?.name ? newValue : null),
                              validator: (value) {
                                if (value!.length <= 2) {
                                  return '이름은 두 글자 이상 입력해야합니다.';
                                }
                                return null;
                              },
                            ),
                            Text('ID: ${user?.email}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),

                    // 평가게이지
                    const HalfCircleGuage(progress: 0.2, size: 270),

                    // 만든모임, 리뷰
                    const Column(
                      children: [
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '87',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '만든모임',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 80),
                            Column(
                              children: [
                                Text(
                                  '15',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '리뷰',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                      ],
                    ),

                    // 자기소개
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '자기소개',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          introdutionText(
                            user?.introdution ?? '없음',
                            isEdit: isEdit,
                            onSaved: ((newValue) =>
                                // 원래 값이랑 똑같은때 null
                                controller.editIntrodution =
                                    newValue != user?.introdution ? newValue : null),
                            validator: (_) => null,
                          ),
                        ],
                      ),
                    ),

                    // 흥미
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '흥미',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                interestItem('독서'),
                                interestItem('프로그래밍'),
                                interestItem('프로그래밍'),
                                interestItem('프'),
                                interestItem('프그래밍'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector imageCircle(String? imageUrl,
      {required bool isEdit, required String? selectedImage}) {
    return GestureDetector(
      onTap: isEdit ? controller.getImage : null,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 40,
              foregroundImage: selectedImage != null
                  ? Image.file(File(selectedImage)).image
                  : imageUrl != null
                      ? Image.network(imageUrl).image
                      : Image.asset(Assets.imageNoImage).image,
              backgroundImage:
                  Image.asset(Assets.imageLoading).image, // 로딩 중일 때 보여줄 이미지
            ),
            if (isEdit)
              const Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  SizedBox introdutionText(
    String introdution, {
    required bool isEdit,
    required FormFieldSetter onSaved,
    required FormFieldValidator validator,
  }) {
    return SizedBox(
      width: 500,
      child: Text(
        '안녕하세요',
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  Widget nameText(
    String name, {
    required bool isEdit,
    required FormFieldSetter onSaved,
    required FormFieldValidator validator,
  }) {
    return SizedBox(
      width: 200,
      height: 50,
      child: !isEdit
          ? Text(name, style: const TextStyle(fontSize: 32))
          : TextFormField(
              onSaved: onSaved,
              validator: validator,
              initialValue: name,
              style: const TextStyle(fontSize: 32),
              autovalidateMode: AutovalidateMode.always,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
            ),
    );
  }

  Container interestItem(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50), // 테두리를 둥글게 만드는 부분
        border: Border.all(
          color: Colors.black,
          width: 1, // 테두리의 두께
        ),
      ),
      child: Text(
        interest,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  PopupMenuItem<String> menuItem(
      {required String text,
      required IconData icon,
      required Color color,
      required VoidCallback ontap}) {
    return PopupMenuItem<String>(
      onTap: ontap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            icon,
            color: color,
          ),
        ],
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
      height: size * 2 / 3,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              painter: HalfCircleGuagePainter(progress),
              child: SizedBox(
                width: size,
                height: size / 5,
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
