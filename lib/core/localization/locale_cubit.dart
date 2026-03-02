import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit() : super(null) {
    _loadLocale();
  }

  static const _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeStr = prefs.getString(_localeKey);
    if (localeStr != null) {
      emit(Locale(localeStr));
    }
  }

  Future<void> setLocale(Locale prefix) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, prefix.languageCode);
    emit(prefix);
  }
}
