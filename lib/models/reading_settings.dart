import 'dart:ui';
import 'package:flutter/material.dart';

class ReadingSettings {
  double fontSize;
  double lineHeight;
  Color backgroundColor;
  Color textColor;
  String fontFamily;
  TextAlign textAlign;

  ReadingSettings({
    this.fontSize = 18.0,
    this.lineHeight = 1.7,
    this.backgroundColor = const Color(0xFF121212),
    this.textColor = const Color(0xFFEAEAEA),
    this.fontFamily = 'Default',
    this.textAlign = TextAlign.left,
  });
}
