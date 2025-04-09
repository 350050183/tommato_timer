import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool vibrationEnabled;
  final bool keepScreenOn;
  final String locale;
  final bool soundEnabled;

  const Settings({
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.vibrationEnabled,
    required this.keepScreenOn,
    required this.locale,
    required this.soundEnabled,
  });

  Settings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? vibrationEnabled,
    bool? keepScreenOn,
    String? locale,
    bool? soundEnabled,
  }) {
    return Settings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      locale: locale ?? this.locale,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'vibrationEnabled': vibrationEnabled,
      'keepScreenOn': keepScreenOn,
      'locale': locale,
      'soundEnabled': soundEnabled,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      keepScreenOn: json['keepScreenOn'] as bool? ?? false,
      locale: json['locale'] as String? ?? 'zh',
      soundEnabled: json['soundEnabled'] as bool? ?? true,
    );
  }

  Future<void> saveToPrefs(SharedPreferences prefs) async {
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setBool('keepScreenOn', keepScreenOn);
    await prefs.setString('locale', locale);
    await prefs.setBool('soundEnabled', soundEnabled);
  }
}

class SettingsModel extends ChangeNotifier {
  Settings _settings = const Settings(
    isDarkMode: false,
    notificationsEnabled: true,
    vibrationEnabled: true,
    keepScreenOn: false,
    locale: 'zh',
    soundEnabled: true,
  );
  SharedPreferences? _prefs;

  SettingsModel({required Settings settings}) : _settings = settings {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Settings get settings => _settings;

  Locale? get locale {
    if (_settings.locale == 'auto') return null;
    if (_settings.locale == 'en') return const Locale('en');
    if (_settings.locale == 'zh') return const Locale('zh');
    return null;
  }

  bool get isDarkMode => _settings.isDarkMode;

  Future<void> updateSettings(Settings newSettings) async {
    _settings = newSettings;
    if (_prefs != null) {
      await newSettings.saveToPrefs(_prefs!);
    }
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(vibrationEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(soundEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setLocale(String locale) async {
    final newSettings = _settings.copyWith(locale: locale);
    await updateSettings(newSettings);
  }

  Future<void> setDarkMode(bool enabled) async {
    final newSettings = _settings.copyWith(isDarkMode: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    final newSettings = _settings.copyWith(keepScreenOn: enabled);
    await updateSettings(newSettings);
  }

  Future<void> loadSettings() async {
    final settingsJson = _prefs?.getString('settings');
    if (settingsJson != null) {
      _settings = Settings.fromJson(
        Map<String, dynamic>.from(json.decode(settingsJson)),
      );
    }
    notifyListeners();
  }

  Future<void> saveSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(
      'settings',
      json.encode(_settings.toJson()),
    );
  }
}
