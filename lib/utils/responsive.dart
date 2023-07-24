import 'package:flutter/material.dart';

class Responsive {
  static DeviceSize _deviceSize = DeviceSize.mobile;
  static DeviceSize get deviceSize => _deviceSize;

  // 화면 가로 길이 설정
  static void init(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    debugPrint('가로길이:${screenWidth.toString()}');
    if (screenWidth >= 1024) {
      _deviceSize = DeviceSize.desktop;
    } else if (screenWidth >= 600) {
      _deviceSize = DeviceSize.tablet;
    } else {
      _deviceSize = DeviceSize.mobile;
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
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
  }) {
    switch (_deviceSize) {
      case DeviceSize.desktop:
        return desktop;
      case DeviceSize.tablet:
        return tablet;
      case DeviceSize.mobile:
      default:
        return mobile;
    }
  }

  static void Function() action({
    required void Function() mobile,
    required void Function() tablet,
    required void Function() desktop,
  }) {
    switch (_deviceSize) {
      case DeviceSize.desktop:
        return desktop;
      case DeviceSize.tablet:
        return tablet;
      case DeviceSize.mobile: 
      default:
        return mobile;
    }
  }
}

enum DeviceSize {
  mobile,
  tablet,
  desktop;
}
