import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> meetingIcon() async {
  const Size size = Size(80, 105); // 아이콘 크기
  final double radius = size.shortestSide / 2;
  final center = Offset(radius, radius);
  const double strokeWidth = 20.0;

  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // 세모 그리기
  final trianglePath = Path();

  trianglePath.moveTo(radius, radius*2+25);
  trianglePath.lineTo(radius/2-5, radius+radius/2);
  trianglePath.lineTo(radius+radius/2+5, radius+radius/2);
  trianglePath.close();

  final trianglePaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  canvas.drawPath(trianglePath, trianglePaint);

  // 원 모양으로 자르기
  Path path = Path()
    ..addOval(Rect.fromLTWH(0, 0, size.shortestSide.toDouble(), size.shortestSide.toDouble()));
  canvas.clipPath(path);

  // 이미지 그리기
  final ui.Image image = await loadImage('assets/images/nuduwa_logo.png');
  final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  final dest = Offset.zero & size;
  canvas.drawImageRect(image, src, dest, Paint());

  // 빨간색 테두리 그리기  
  final paint = Paint();
  paint.color = Colors.red;
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = strokeWidth;
  canvas.drawCircle(center, radius, paint);  
  

  // 최종 이미지를 바이트 데이터로 변환
  final Picture picture = recorder.endRecording();
  final ui.Image markerImage = await picture.toImage(size.width.toInt(), size.height.toInt());
  final ByteData? byteData = await markerImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List byteList = byteData!.buffer.asUint8List();

  // BitmapDescriptor로 변환하여 반환
  return BitmapDescriptor.fromBytes(byteList);
}

Future<ui.Image> loadImage(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image image) {
    completer.complete(image);
  });
  return completer.future;
}