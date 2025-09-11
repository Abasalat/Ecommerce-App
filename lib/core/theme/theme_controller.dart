import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  static void set(ThemeMode newMode) => mode.value = newMode;

  static void toggle(Brightness currentBrightness) {
    final isDarkNow =
        mode.value == ThemeMode.dark ||
        (mode.value == ThemeMode.system &&
            currentBrightness == Brightness.dark);
    mode.value = isDarkNow ? ThemeMode.light : ThemeMode.dark;
  }
}
