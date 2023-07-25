import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/profileController/user_profile_controller.dart';
import 'package:nuduwa_with_flutter/pages/scaffold_of_nuduwa.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/utils/assets.dart';

class UserProfilePage extends StatelessWidget {
  UserProfilePage({super.key});

  final controller = Get.put(UserProfileController(uid: Get.arguments));

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ScaffoldOfNuduwa(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              size: 32,
              color: Colors.black,
            ),
            onPressed: Get.back,
          ),
        ),
        body: Obx(() {
          final user = controller.user.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!) as ImageProvider
                          : const AssetImage(Assets.imageNoImage),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      user.name ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    if (controller.uid != FirebaseService.instance.currentUid)
                    IconButton(
                      onPressed: controller.clickedChattingButton,
                      icon: const Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 32,
                          ),
                          Text('1:1 채팅'),
                        ],
                      ),
                      iconSize: 64,
                    ),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}