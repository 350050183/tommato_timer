import 'package:flutter/material.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String translate(String key) {
    // 这里可以添加实际的翻译逻辑
    // 目前返回key作为占位符
    return key;
  }
}
