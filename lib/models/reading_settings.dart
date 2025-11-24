import 'dart:ui';

class ReadingSettings {
  double fontSize;
  Color backgroundColor;
  Color textColor;
  String fontFamily;

  ReadingSettings({
    this.fontSize = 18.0,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF212121),
    this.fontFamily = 'Default',
  });
}
