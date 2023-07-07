import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nuduwa_with_flutter/controller/mapController/create_meeting_controller.dart';
import 'package:numberpicker/numberpicker.dart';

Future<dynamic> createMeetingSheet(BuildContext context, LatLng location) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15.0),
      ),
    ),
    barrierColor: Colors.white.withOpacity(0),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (BuildContext context) => CreateMeetingScreen(location: location),
  );
}

class CreateMeetingScreen extends StatelessWidget {
  final LatLng location;
  const CreateMeetingScreen({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateMeetingController(location));

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
              onTap: () {
                // 터치 이벤트 발생 시 키보드를 숨깁니다.
                FocusScope.of(context).unfocus();
              },
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
                            Text(controller.address.value),
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
                  SizedBox(width: 5),
                  Text('모임 생성'),
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
    return Container(
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _controller.category = '운동';
              });
            },
            child: Text('운동'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(
                _controller.category == '운동' ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 5),
          TextButton(
            onPressed: () {
              setState(() {
                _controller.category = '공부';
              });
            },
            child: Text('공부'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(
                _controller.category == '공부' ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 5),
          TextButton(
            onPressed: () {
              setState(() {
                _controller.category = '먹기';
              });
            },
            child: Text('먹기'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(
                _controller.category == '먹기' ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
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
              Text(
                '최대 인원수 : ',
                style: const TextStyle(
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
              Text(
                '명',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 40),
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
        DateTime.now().add(const Duration(minutes: 5)); //현재시간+5분;
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Text(title),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          margin: const EdgeInsets.all(5.0),
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
    );
  }
}

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
