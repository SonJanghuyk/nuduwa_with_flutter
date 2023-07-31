import 'package:flutter/material.dart';
import 'package:nuduwa_with_flutter/components/nuduwa_colors.dart';

class NuduwaThemes {
  static ThemeData get lightTheme => ThemeData(
        primarySwatch: NuduwaColors.primaryMaterialColor,
        fontFamily: 'OmyuPretty',
        scaffoldBackgroundColor: Colors.white,
        // splashColor: Colors.white,
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        brightness: Brightness.light,
        useMaterial3: true,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          enableFeedback: false,
        ),
      );
  static ThemeData get dartTheme => ThemeData(
        primarySwatch: NuduwaColors.primaryMaterialColor,
        fontFamily: 'OmyuPretty',
        // splashColor: Colors.white,
        textTheme: _textTheme,
        brightness: Brightness.dark,
        useMaterial3: true,
      );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(
      color: NuduwaColors.primaryColor,
    ),
    elevation: 0,
  );

  static const TextTheme _textTheme = TextTheme(
    headline4: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    subtitle1: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    subtitle2: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyText1: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w300,
    ),
    bodyText2: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w300,
    ),
    button: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w300,
    ),
  );
}
