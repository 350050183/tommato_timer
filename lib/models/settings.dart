import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int sessionsBeforeLongBreak;
  final bool notificationsEnabled;
  final bool vibrationEnabled;
  final bool keepScreenOn;
  final String locale;
  final bool isDarkMode;

  Settings({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.notificationsEnabled = true,
    this.vibrationEnabled = true,
    this.keepScreenOn = true,
    this.locale = 'auto',
    this.isDarkMode = false,
  });

  factory Settings.fromPrefs(SharedPreferences prefs) {
    return Settings(
      workDurationMinutes: prefs.getInt('workDurationMinutes') ?? 25,
      shortBreakDurationMinutes: prefs.getInt('shortBreakDurationMinutes') ?? 5,
      longBreakDurationMinutes: prefs.getInt('longBreakDurationMinutes') ?? 15,
      sessionsBeforeLongBreak: prefs.getInt('sessionsBeforeLongBreak') ?? 4,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      keepScreenOn: prefs.getBool('keepScreenOn') ?? true,
      locale: prefs.getString('locale') ?? 'auto',
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
    );
  }

  Future<void> saveToPrefs(SharedPreferences prefs) async {
    await prefs.setInt('workDurationMinutes', workDurationMinutes);
    await prefs.setInt('shortBreakDurationMinutes', shortBreakDurationMinutes);
    await prefs.setInt('longBreakDurationMinutes', longBreakDurationMinutes);
    await prefs.setInt('sessionsBeforeLongBreak', sessionsBeforeLongBreak);
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setBool('keepScreenOn', keepScreenOn);
    await prefs.setString('locale', locale);
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Settings copyWith({
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? sessionsBeforeLongBreak,
    bool? notificationsEnabled,
    bool? vibrationEnabled,
    bool? keepScreenOn,
    String? locale,
    bool? isDarkMode,
  }) {
    return Settings(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsModel extends ChangeNotifier {
  Settings _settings;
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

  Future<void> setWorkDuration(int minutes) async {
    final newSettings = _settings.copyWith(workDurationMinutes: minutes);
    await updateSettings(newSettings);
  }

  Future<void> setShortBreakDuration(int minutes) async {
    final newSettings = _settings.copyWith(shortBreakDurationMinutes: minutes);
    await updateSettings(newSettings);
  }

  Future<void> setLongBreakDuration(int minutes) async {
    final newSettings = _settings.copyWith(longBreakDurationMinutes: minutes);
    await updateSettings(newSettings);
  }

  Future<void> setSessionsBeforeLongBreak(int sessions) async {
    final newSettings = _settings.copyWith(sessionsBeforeLongBreak: sessions);
    await updateSettings(newSettings);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(vibrationEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    final newSettings = _settings.copyWith(keepScreenOn: enabled);
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
}
