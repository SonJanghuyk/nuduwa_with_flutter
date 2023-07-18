import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/controller/mapController/create_meeting_controller.dart';
import 'package:nuduwa_with_flutter/model/meeting.dart';
import 'package:numberpicker/numberpicker.dart';

Future<dynamic> createMeetingSheet() {
  return showModalBottomSheet(
    context: Get.context!,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    barrierColor: Colors.white.withOpacity(0),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (_) => CreateMeetingScreen(),
  );
}

class CreateMeetingScreen extends StatelessWidget {
  final controller = Get.put(CreateMeetingController());

  CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.transparent.withOpacity(0.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단바 뒤로가기 아이콘
          IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
            ),
            color: Colors.blue,
          ),

          // 모임 정보 입력창
          Expanded(
            child: GestureDetector(
              // 터치 이벤트 발생 시 키보드를 숨깁니다.
              onTap: FocusScope.of(context).unfocus,
              child: Container(
                padding: const EdgeInsets.all(5.0),
                color: const Color.fromARGB(29, 3, 168, 244),
                child: ListView(
                  children: [
                    const SizedBox(height: 5),

                    // 모임 정보 컨테이너
                    MeetingSetContainer(
                      title: '모임정보',
                      content: [
                        setTextfiled(controller.title, '모임 제목 입력'),
                        const SizedBox(height: 8),
                        setTextfiled(controller.description, '모임 내용 입력'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 모임 장소 컨테이너
                    MeetingSetContainer(
                      title: '장소',
                      content: [
                        Row(
                          children: [
                            Obx(() => Text(controller.address.value, overflow: TextOverflow.ellipsis, maxLines: 1)),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        setTextfiled(controller.place, '모임 상세장소 입력'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 모임 시간 컨테이너
                    MeetingSetContainer(
                      title: '시간',
                      content: [
                        TimePicker(
                          controller: controller,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 최대 인원수 컨테이너
                    MeetingSetContainer(
                      title: '최대 인원수',
                      content: [
                        MaxNumberPicker(
                          controller: controller,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 카테고리 컨테이너
                    MeetingSetContainer(
                      title: '카테고리',
                      content: [
                        CategoryPicker(
                          controller: controller,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 하단바 버튼
          Center(
            child: TextButton(
              onPressed: () {
                controller.createMeeting();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_task),
                  SizedBox(width: 5, height: 50),
                  Text('모임 생성', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 텍스트 입력 필드
  TextFormField setTextfiled(RxString content, String hint) {
    const outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(5.0),
      ),
    );
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return '모임 제목을 입력해주세요';
        }
        return null;
      },
      onChanged: (value) => content.value = value,
      decoration: InputDecoration(
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
        contentPadding: const EdgeInsets.all(10.0),
      ),
    );
  }
}

// 카테고리 선택 위젯
class CategoryPicker extends StatefulWidget {
  final CreateMeetingController controller;

  const CategoryPicker({
    super.key,
    required this.controller,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  late CreateMeetingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final category in MeetingCategory.values)
          pickButton(category.displayName),
      ],
    );
  }

  Padding pickButton(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 5),
      child: TextButton(
        onPressed: () {
          setState(() {
            _controller.category = category;
          });
        },
        style: ButtonStyle(
          fixedSize: const MaterialStatePropertyAll<Size>(Size(80, 10)),
          foregroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
          backgroundColor: MaterialStatePropertyAll<Color>(
            _controller.category == category ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          category,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}

// 최대인원수 선택 위젯
class MaxNumberPicker extends StatefulWidget {
  final CreateMeetingController controller;

  const MaxNumberPicker({
    super.key,
    required this.controller,
  });

  @override
  State<MaxNumberPicker> createState() => _MaxNumberPickerState();
}

class _MaxNumberPickerState extends State<MaxNumberPicker> {
  late CreateMeetingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.maxMemers = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                '최대 인원수 : ',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              NumberPicker(
                itemWidth: 50,
                minValue: 1,
                maxValue: 10,
                value: _controller.maxMemers,
                itemCount: 1,
                textStyle: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
                selectedTextStyle: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
                onChanged: (value) =>
                    setState(() => _controller.maxMemers = value),
              ),
              const Text(
                '명',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Column(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (_controller.maxMemers < 10) {
                  _controller.maxMemers += 1;
                }
              }),
              icon: const Icon(
                Icons.arrow_drop_up,
                size: 35,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                if (_controller.maxMemers > 2) {
                  _controller.maxMemers -= 1;
                }
              }),
              icon: const Icon(
                Icons.arrow_drop_down,
                size: 35,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 모임 시간 설정 위젯
class TimePicker extends StatefulWidget {
  final CreateMeetingController controller;

  const TimePicker({
    super.key,
    required this.controller,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late CreateMeetingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.meetingTime =
        DateTime.now().add(const Duration(minutes: 5)); //현재 한국시간+5분;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Column(
              children: [
                TextButton(
                  child: Text(
                    '오늘',
                    style: TextStyle(
                      fontSize: 25,
                      color: _controller.meetingTime.day == DateTime.now().day
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.meetingTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          _controller.meetingTime.hour,
                          _controller.meetingTime.minute);
                    });
                  },
                ),
                TextButton(
                  child: Text(
                    '내일',
                    style: TextStyle(
                      fontSize: 25,
                      color: _controller.meetingTime.day != DateTime.now().day
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.meetingTime.day == DateTime.now().day) {}

                      _controller.meetingTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().add(const Duration(days: 1)).day,
                          _controller.meetingTime.hour,
                          _controller.meetingTime.minute);
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            TimePickerSpinner(
              is24HourMode: false,
              time: _controller.meetingTime,
              normalTextStyle: const TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
              isForce2Digits: true,
              onTimeChange: (time) {
                setState(() {
                  _controller.meetingTime = time;
                });
              },
            ),
            const Spacer(),
          ],
        ),
        Text(
          '${_controller.meetingTime.month.toString().padLeft(2, '0')}월 ${_controller.meetingTime.day.toString().padLeft(2, '0')}일 ${_controller.meetingTime.hour.toString().padLeft(2, '0')}시 ${_controller.meetingTime.minute.toString().padLeft(2, '0')}분',
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}

class MeetingSetContainer extends StatelessWidget {
  final String title;
  final List<Widget> content;

  const MeetingSetContainer({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final widthOfWidget = width > 830 ? 800.0 : width - 30;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(title),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            margin: const EdgeInsets.all(5.0),
            width: widthOfWidget - 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 1,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Form(
              child: Column(
                children: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 삭제 예정
class SampleMeetingSetContainer extends StatefulWidget {
  const SampleMeetingSetContainer({
    super.key,
  });

  @override
  State<SampleMeetingSetContainer> createState() =>
      _SampleMeetingSetContainerState();
}

class _SampleMeetingSetContainerState extends State<SampleMeetingSetContainer> {
  bool isSignUpScreen = true;

  @override
  Widget build(BuildContext context) {
    const outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(35.0),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(20.0),
      height: 280.0,
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSignUpScreen = false;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !isSignUpScreen ? Colors.black : Colors.grey),
                    ),
                    if (!isSignUpScreen) // inline if 기능, children내에서만 사용
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        height: 2,
                        width: 55,
                        color: Colors.orange,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSignUpScreen = true;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'SignUp',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSignUpScreen ? Colors.black : Colors.grey),
                    ),
                    if (isSignUpScreen) // inline if 기능, children내에서만 사용
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        height: 2,
                        width: 55,
                        color: Colors.orange,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '모임 제목을 입력해주세요';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                      ),
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      hintText: '모임 제목 입력',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '모임 내용을 입력해주세요';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Colors.grey,
                      ),
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      hintText: '모임 내용 입력',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
