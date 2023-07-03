import 'package:flutter/material.dart';

class MeetingSetSheet extends StatelessWidget {
  const MeetingSetSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.all(10),
      color: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.blue,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ListView(
                children: [
                  Text('모임정보'),
                  MeetingSetContainer(),
                  SizedBox(height: 50),
                  Text('장소'),
                  Column(
                    children: [
                      TextFormField(),
                    ],
                  ),
                  SizedBox(height: 50),
                  Text('시간'),
                  SizedBox(height: 50),
                  Text('최대 인원수'),
                  SizedBox(height: 50),
                  Text('카테고리'),
                ],
              ),
            ),
          ),
          Center(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_task),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class MeetingSetContainer extends StatefulWidget {
  const MeetingSetContainer({
    super.key,
  });

  @override
  State<MeetingSetContainer> createState() => _MeetingSetContainerState();
}

class _MeetingSetContainerState extends State<MeetingSetContainer> {
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
