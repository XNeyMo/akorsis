import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale_code';
  Box? _settingsBox;

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('es'), // Spanish
    Locale('en'), // English
  ];

  LocaleCubit() : super(const Locale('es')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      _settingsBox = await Hive.openBox(_boxName);
      final localeCode = _settingsBox?.get(_localeKey, defaultValue: 'es') ?? 'es';
      emit(Locale(localeCode));
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      if (_settingsBox == null) {
        _settingsBox = await Hive.openBox(_boxName);
      }
      await _settingsBox?.put(_localeKey, locale.languageCode);
      emit(locale);
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'es' 
        ? const Locale('en') 
        : const Locale('es');
    setLocale(newLocale);
  }

  bool get isSpanish => state.languageCode == 'es';
  bool get isEnglish => state.languageCode == 'en';

  String get currentLanguageName => state.languageCode == 'es' ? 'Español' : 'English';
}
