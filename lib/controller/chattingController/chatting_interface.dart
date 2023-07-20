import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/model/message.dart';

interface class ChattingController extends GetxController {
  final messages = <Message>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  var isNotLast = false.obs;

   Future<void> sendMessage() async {
    ///
  }

  void scrollLast() {
    ///
  }
}