import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_page_route.dart';
import 'package:nuduwa_with_flutter/constants/nuduwa_widgets.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_detail_controller.dart';
import 'package:nuduwa_with_flutter/pages/map/sub/meeting_info_sheet.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';
import 'package:nuduwa_with_flutter/constants/assets.dart';

class MeetingDetailPage extends GetView<MeetingDetailController> {
  const MeetingDetailPage({
    super.key,
    required this.meetingId,
    required this.onClose,
  });

  final String meetingId;
  final void Function(BuildContext) onClose;

  @override
  String? get tag => meetingId;

  @override
  Widget build(BuildContext context) {
    return ScaffoldOfNuduwa(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        leading: Obx(() {
          final isEdit = controller.isEdit.value;
          if (isEdit) {
            // 수정 중일때 - 수정취소 버튼
            return IconButton(
              onPressed: controller.cancelEdit,
              icon: const Row(children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.red,
                  size: 28,
                ),
                Text(
                  '수정 취소',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
              ]),
              color: Colors.blue,
            );
          } else {
            // 뒤로가기 버튼
            return IconButton(
              onPressed: () => onClose(context),
              icon: const Row(children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 28,
                  color: Colors.blue,
                ),
                Text(
                  '내 모임',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ]),
            );
          }
        }),
        leadingWidth: 130,
        actions: [
          Obx(
            () {
              final isLoading = controller.isLoading.value;
              final isEdit = controller.isEdit.value;
              final isHost = controller.meeting.value?.hostUid ==
                  FirebaseAuth.instance.currentUser?.uid;
              if (isLoading) {
                // 수정 로딩중일때
                return const Center(child: CircularProgressIndicator());
              } else if (isEdit) {
                // 수정 중일때 - 수정완료 버튼
                return IconButton(
                  onPressed: controller.updateEdit,
                  icon: const Text(
                    '수정 완료',
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  color: Colors.blue,
                  iconSize: 80,
                );
              } else {
                // 메뉴 버튼
                return PopupMenuButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.blue,
                  ),
                  iconSize: 30,
                  elevation: 1,
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  itemBuilder: (BuildContext context) => isHost
                      ? <PopupMenuEntry<String>>[
                          //
                          // 모임 Host일때
                          //
                          menuItem(
                            text: '모임 수정',
                            icon: Icons.change_circle_outlined,
                            color: Colors.black,
                            ontap: controller.onEdit,
                          ),
                          menuItem(
                            text: '모임 삭제',
                            icon: Icons.delete_forever_outlined,
                            color: Colors.red,
                            ontap: () => {},
                          ),
                        ]
                      : [
                          //
                          // 모임 Host 아닐때
                          //
                          menuItem(
                              text: '모임 나가기',
                              icon: Icons.exit_to_app,
                              color: Colors.red,
                              ontap: () {
                                controller.leaveMeeting();
                                () => onClose(context);
                              })
                        ],
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final meeting = controller.meeting.value;
        if (meeting == null) {
          // 서버에서 데이터 가져오는 중일때
          return const Center(child: CircularProgressIndicator());
        } else {
          // 서버에서 데이터 가져왔을 때
          return GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                foregroundImage: meeting.hostImageUrl != null
                                    ? NetworkImage(meeting.hostImageUrl!)
                                        as ImageProvider
                                    : const AssetImage(Assets.imageNoImage),
                                backgroundImage: const AssetImage(
                                    Assets.imageLoading), // 로딩 중일 때 보여줄 배경색
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ------- HostName -------
                                  SizedBox(
                                    height: 22,
                                    child: meeting.hostName == null
                                        ? const SizedBox(
                                            width: 20,
                                            child: CircularProgressIndicator())
                                        : Text(meeting.hostName!,
                                            style:
                                                const TextStyle(fontSize: 17)),
                                  ),
                                  const SizedBox(height: 5),

                                  // ------- PublishedTime -------
                                  Text(
                                    '${DateFormat("y년 M월 d일 a h:mm").format(meeting.publishedTime)}에 생성됨',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                // ------- Title -------
                                Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: EditTextFormField(
                                      text: meeting.title,
                                      icon: null,
                                      size: 50,
                                      maxLines: 2,
                                      isEdit: controller.isEdit,
                                      onSaved: (newValue) =>
                                          // 원래 값이랑 똑같은때 null
                                          controller.editTitle =
                                              newValue != meeting.title
                                                  ? newValue
                                                  : null,
                                      validator: (value) {
                                        if (value.length < 2) {
                                          return '제목은 두 글자 이상 입력해야합니다.';
                                        }
                                        return null;
                                      },
                                    )),
                                const SizedBox(height: 40),

                                // ------- Description -------
                                EditTextFormField(
                                  text: meeting.description,
                                  icon: Icons.edit_outlined,
                                  size: 22,
                                  maxLines: 10,
                                  isEdit: controller.isEdit,
                                  onSaved: (newValue) =>
                                      // 원래 값이랑 똑같은때 null
                                      controller.editDescription =
                                          newValue != meeting.description
                                              ? newValue
                                              : null,
                                  validator: (value) {
                                    if (value.length < 1) {
                                      return '내용은 한 글자 이상 입력해야합니다.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 40),

                                // ------- Place -------
                                EditTextFormField(
                                  text: meeting.place,
                                  icon: Icons.location_on_outlined,
                                  size: 22,
                                  maxLines: 3,
                                  isEdit: controller.isEdit,
                                  onSaved: (newValue) =>
                                      // 원래 값이랑 똑같은때 null
                                      controller.editPlace =
                                          newValue != meeting.place
                                              ? newValue
                                              : null,
                                  validator: (value) {
                                    if (value.length < 1) {
                                      return '장소는 한 글자 이상 입력해야합니다.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 40),

                                // MeetingTime
                                RowMeetingInfo(
                                  text:
                                      '${DateFormat("M월 d일 a h:mm").format(meeting.meetingTime)}에 만나요!',
                                  icon: Icons.calendar_month,
                                  // isEdit: controller.isEdit,
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),

                          // Members
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5,
                                  spreadRadius: 2.5,
                                )
                              ],
                              color: Colors.white,
                            ),
                            child: Column(children: [
                              const Text('참여자'),
                              Obx(() {
                                final members = controller.members.values;
                                return Wrap(
                                  children: [
                                    for (final member in members)
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: IconButton(
                                          onPressed: () => Get.toNamed(
                                            RoutePages.userProfile(
                                                uid: member.uid),
                                          ),
                                          icon: CircleAvatar(
                                            radius: 20,
                                            foregroundImage: member.imageUrl !=
                                                    null
                                                ? NetworkImage(member.imageUrl!)
                                                    as ImageProvider
                                                : const AssetImage(
                                                    Assets.imageNoImage),
                                            backgroundImage: const AssetImage(Assets
                                                .imageLoading), // 로딩 중일 때 보여줄 배경색
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                  !controller.isEdit.value
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextButton(
                              onPressed: controller.enterMeetingChat,
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                  fixedSize: MaterialStateProperty.all(
                                      const Size(200, 45))),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_outlined,
                                      color: Colors.white),
                                  SizedBox(width: 5, height: 50),
                                  Text(
                                    '채팅 참가',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const Center()
                ],
              ),
            ),
          );
        }
      }),
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

class EditTextFormField extends StatelessWidget {
  final String text;
  final IconData? icon;
  final double size;
  final int maxLines;
  final Rx<bool> isEdit;
  final FormFieldSetter onSaved;
  final FormFieldValidator validator;

  const EditTextFormField({
    super.key,
    required this.text,
    required this.icon,
    required this.size,
    required this.maxLines,
    required this.isEdit,
    required this.onSaved,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Icon(
            icon,
            size: size,
          ),
        const SizedBox(width: 5),
        Obx(() => Expanded(
              child: !isEdit.value
                  ? Text(text,
                      style: TextStyle(fontSize: size),
                      overflow: TextOverflow.ellipsis,
                      maxLines: maxLines)
                  : TextFormField(
                      onSaved: onSaved,
                      validator: validator,
                      initialValue: text,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
            )),
      ],
    );
  }
}
