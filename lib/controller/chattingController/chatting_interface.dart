import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuduwa_with_flutter/models/message.dart';

abstract interface class ChattingController extends GetxController {
  final messages = RxList<Message>();
  final textController = TextEditingController();
  final scrollController = ScrollController();

  var isNotLast = RxBool(false);

  Stream<List<Message>> streamForMessages();

  Future<void> sendMessage();

  void scrollLast();
}