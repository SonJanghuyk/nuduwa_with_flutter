import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nuduwa_with_flutter/controller/meetingController/meeting_card_controller.dart';
import 'package:nuduwa_with_flutter/main.dart';
import 'package:nuduwa_with_flutter/screens/map/sub/meeting_info_sheet.dart';
import 'package:nuduwa_with_flutter/screens/meeting/sub/meeting_chat_page.dart';
import 'package:nuduwa_with_flutter/service/firebase_service.dart';

class MeetingDetailPage extends StatelessWidget {
  final MeetingCardController controller;
  final VoidCallback onClose;

  MeetingDetailPage(
      {super.key, required this.controller, required this.onClose}) {
    controller.listenerForMembers(controller.meeting.value!.id!);
  }

  @override
  Widget build(BuildContext context) {
    final isHost =
        controller.userMeeting.hostUid == FirebaseService.instance.currentUid!;

    return Scaffold(
      appBar: AppbarOfNuduwa(
        title: '',
        iconButtons: [
          Expanded(
            child: Obx(() => !controller.isEdit.value
                ? IconButton(
                    onPressed: onClose,
                    icon: const Row(children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 28,
                      ),
                      Text(
                        '내 모임',
                        style: TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                    ]),
                    color: Colors.blue,
                  )
                : IconButton(
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
                  )),
          ),
          const Spacer(),
          Obx(
            () => !controller.isEdit.value
                ? PopupMenuButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.blue,
                    ),
                    iconSize: 30,
                    elevation: 1,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.expand(
                        width: 150, height: isHost ? 100 : 40),
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    itemBuilder: (BuildContext context) => isHost
                        ? <PopupMenuEntry<String>>[
                            meetingMenuItem(
                              text: '모임 수정',
                              icon: Icons.change_circle_outlined,
                              color: Colors.black,
                              ontap: controller.onEdit,
                            ),
                            meetingMenuItem(
                              text: '모임 삭제',
                              icon: Icons.delete_forever_outlined,
                              color: Colors.red,
                              ontap: onClose,
                            ),
                          ]
                        : [
                            meetingMenuItem(
                                text: '모임 나가기',
                                icon: Icons.exit_to_app,
                                color: Colors.red,
                                ontap: controller.leaveMeeting,
                                )
                          ],
                  )
                : Expanded(
                    child: Obx(() => !controller.isLoading.value
                        ? IconButton(
                            onPressed: controller.updateEdit,
                            icon: const Text(
                              '수정 완료',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.blue),
                            ),
                            color: Colors.blue,
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          )),
                  ),
          )
        ],
      ),
      body: Obx(() {
        final meeting = controller.meeting.value;
        if (meeting == null) {
          // 서버에서 데이터 가져오는 중일때
          return const Center(child: CircularProgressIndicator());
        } else {
          // 서버에서 데이터 가져왔을 때
          return Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // ------- HostImage -------
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Obx(() =>
                                  controller.hostImage.value == null
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              controller.hostImage.value,
                                          backgroundColor:
                                              Colors.white, // 로딩 중일 때 보여줄 배경색
                                        )),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ------- HostName -------
                                Text(meeting.hostName!,
                                    style: const TextStyle(fontSize: 15)),

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
                              // ------- Title -------
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 30),
                                  child: EditTextFormField(
                                    text: meeting.title,
                                    icon: null,
                                    size: 50,
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

                              // ------- Place -------
                              EditTextFormField(
                                text: meeting.place,
                                icon: Icons.location_on_outlined,
                                size: 22,
                                isEdit: controller.isEdit,
                                onSaved: (newValue) =>
                                    // 원래 값이랑 똑같은때 null
                                    controller.editPlace =
                                        newValue != meeting.place
                                            ? newValue
                                            : null,
                                validator: (value) {
                                  if (value.length < 1)
                                    return '장소는 한 글자 이상 입력해야합니다.';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),

                              // ------- Description -------
                              EditTextFormField(
                                text: meeting.description,
                                icon: Icons.edit_outlined,
                                size: 22,
                                isEdit: controller.isEdit,
                                onSaved: (newValue) =>
                                    // 원래 값이랑 똑같은때 null
                                    controller.editDescription =
                                        newValue != meeting.description
                                            ? newValue
                                            : null,
                                validator: (value) {
                                  if (value.length < 1)
                                    return '내용은 한 글자 이상 입력해야합니다.';
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            Obx(() => Wrap(
                                  children: [
                                    for (final member
                                        in controller.members.values)
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: SizedBox(
                                          width: 35,
                                          height: 35,
                                          child: member.imageUrl == null
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : CircleAvatar(
                                                  radius: 18,
                                                  backgroundImage: NetworkImage(
                                                      member.imageUrl!),
                                                  backgroundColor: Colors
                                                      .white, // 로딩 중일 때 보여줄 배경색
                                                ),
                                        ),
                                      ),
                                  ],
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: TextButton(
                      onPressed: () => Get.to(MeetingChatPage(controller: controller,)),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blue),
                          fixedSize:
                              MaterialStateProperty.all(const Size(200, 45))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_outlined, color: Colors.white),
                          SizedBox(width: 5, height: 50),
                          Text(
                            '채팅 참가',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  PopupMenuItem<String> meetingMenuItem(
      {required String text,
      required IconData icon,
      required Color color,
      required VoidCallback ontap}) {
    return PopupMenuItem<String>(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Center(
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
        ),
      ),
    );
  }
}

class EditTextFormField extends StatelessWidget {
  final String text;
  final IconData? icon;
  final double size;
  final Rx<bool> isEdit;
  final FormFieldSetter onSaved;
  final FormFieldValidator validator;

  const EditTextFormField({
    super.key,
    required this.text,
    required this.icon,
    required this.size,
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
        Obx(() => !isEdit.value
            ? SizedBox(
              width: icon!=null ? 330 : 322,
              child: Text(
                  text,
                  style: TextStyle(fontSize: size),
                  overflow: TextOverflow.ellipsis,
                  maxLines: icon!=null ? 5 : 1,
                ),
            )
            : SizedBox(
                width: icon!=null ? 330 : 322,
                height: 70,
                child: TextFormField(
                  onSaved: onSaved,
                  validator: validator,
                  initialValue: text,
                  autovalidateMode: AutovalidateMode.always,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),),
                  ),
                ),
              )),
      ],
    );
  }
}