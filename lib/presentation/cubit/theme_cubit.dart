import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';
  Box? _settingsBox;

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      _settingsBox = await Hive.openBox(_boxName);
      final isDark = _settingsBox?.get(_themeKey, defaultValue: false) ?? false;
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_boxName);
      }
      final isDark = state == ThemeMode.dark;
      await _settingsBox?.put(_themeKey, !isDark);
      emit(isDark ? ThemeMode.light : ThemeMode.dark);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
