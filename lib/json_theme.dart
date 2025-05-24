import 'package:flutter/material.dart';

class JsonThemeInterpreter {
  final Map<String, dynamic>? theme;
  final Map<String, dynamic>? textStyles;
  JsonThemeInterpreter(this.theme, this.textStyles);

  ThemeData toThemeData() {
    return ThemeData(
      primaryColor: _parseColor(theme?['primaryColor']) ?? Colors.blue,
      scaffoldBackgroundColor:
          _parseColor(theme?['backgroundColor']) ?? Colors.white,
      textTheme: const TextTheme(), // TODO: parse textStyles
    );
  }

  Color? _parseColor(dynamic colorString) {
    if (colorString is String && colorString.startsWith('#')) {
      final hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }
}
