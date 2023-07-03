import 'package:flutter/material.dart';

class MeetingInfoSheet extends StatelessWidget {
  const MeetingInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Text('data')
        ],
      ),
    );
  }
}