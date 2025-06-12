import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.lightGreen,
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.lightGreen,
    brightness: Brightness.dark,
  ),
);

extension ThemeExtension on BuildContext {
  /// 获取当前主题的 TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 获取当前主题的 ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
