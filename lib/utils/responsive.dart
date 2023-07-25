import 'package:flutter/material.dart';

class Responsive {
  static DeviceSize _deviceSize = DeviceSize.portrait;
  static DeviceSize get deviceSize => _deviceSize;

  // 화면 가로 길이 설정
  static void init(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('가로길이:${screenWidth.toString()}');
    if (screenWidth >= 840) {
      _deviceSize = DeviceSize.landscape;
    } else {
      _deviceSize = DeviceSize.portrait;
    }
  }

  // 가로 길이에 따라 다른 폰트 크기 반환
  // static double fontSize(double mobileSize, double tabletSize, double desktopSize) {
  //   if (_screenWidth >= 1024) {
  //     return desktopSize;
  //   } else if (_screenWidth >= 600) {
  //     return tabletSize;
  //   } else {
  //     return mobileSize;
  //   }
  // }

  // 가로 길이에 따라 다른 패딩 값 반환
  // static double padding(double mobilePadding, double tabletPadding, double desktopPadding) {
  //   if (_screenWidth >= 1024) {
  //     return desktopPadding;
  //   } else if (_screenWidth >= 600) {
  //     return tabletPadding;
  //   } else {
  //     return mobilePadding;
  //   }
  // }

  // 가로 길이에 따라 다른 레이아웃 반환
  static Widget layout({
    required Widget portrait,
    required Widget landscape,
  }) {
    switch (_deviceSize) {
      case DeviceSize.portrait:
        return portrait;
      case DeviceSize.landscape:
        return landscape;
    }
  }

  static void Function() action({
    required void Function() portrait,
    required void Function() landscape,
  }) {
    switch (_deviceSize) {
      case DeviceSize.portrait:
        return portrait;
      case DeviceSize.landscape:
        return landscape;
    }
  }
}

enum DeviceSize {
  portrait,
  landscape,
}
