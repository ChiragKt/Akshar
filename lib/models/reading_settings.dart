import 'package:flutter/material.dart';

class ReadingSettings {
  double fontSize;
  double lineHeight;
  Color backgroundColor;
  Color textColor;
  String fontFamily;
  TextAlign textAlign;

  static final ReadingSettings shared = ReadingSettings();

  static const List<Color> themes = [
    Color(0xFF000000),
    Color(0xFF121212),
    Color(0xFF2C2C2C),
    Color(0xFFFFFFFF),
    Color(0xFFE8DCC0),
  ];

  ReadingSettings({
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.backgroundColor = const Color(0xFF121212),
    this.textColor = Colors.white,
    this.fontFamily = 'sans',
    this.textAlign = TextAlign.left,
  });
}
