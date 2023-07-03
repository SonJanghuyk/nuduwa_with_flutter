import 'package:flutter/material.dart';

class MeetingSetSheet extends StatelessWidget {
  const MeetingSetSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.all(10),
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
              padding: const EdgeInsets.fromLTRB(20,0,20,0),
              child: ListView(
                children: const [
                  Text('모임정보'),
                  Column(
                    children: [
                      TextField(),
                      TextField(),
                    ],
                  ),
                  SizedBox(height: 50),
                  Text('장소'),
                  Column(
                    children: [
                      TextField(),
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
