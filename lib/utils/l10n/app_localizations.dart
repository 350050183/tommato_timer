import 'package:flutter/material.dart';

import 'en.dart';
import 'zh.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'zh': zh,
  };

  String get appName =>
      _localizedValues[locale.languageCode]?['appName'] ?? en['appName']!;
  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? en['settings']!;
  String get notifications =>
      _localizedValues[locale.languageCode]?['notifications'] ??
      en['notifications']!;
  String get display =>
      _localizedValues[locale.languageCode]?['display'] ?? en['display']!;
  String get about =>
      _localizedValues[locale.languageCode]?['about'] ?? en['about']!;
  String get enableNotifications =>
      _localizedValues[locale.languageCode]?['enableNotifications'] ??
      en['enableNotifications']!;
  String get enableVibration =>
      _localizedValues[locale.languageCode]?['enableVibration'] ??
      en['enableVibration']!;
  String get keepScreenOn =>
      _localizedValues[locale.languageCode]?['keepScreenOn'] ??
      en['keepScreenOn']!;
  String get darkMode =>
      _localizedValues[locale.languageCode]?['darkMode'] ?? en['darkMode']!;
  String get language =>
      _localizedValues[locale.languageCode]?['language'] ?? en['language']!;
  String get version =>
      _localizedValues[locale.languageCode]?['version'] ?? en['version']!;
  String get feedback =>
      _localizedValues[locale.languageCode]?['feedback'] ?? en['feedback']!;
  String get privacyPolicy =>
      _localizedValues[locale.languageCode]?['privacyPolicy'] ??
      en['privacyPolicy']!;
  String get termsOfService =>
      _localizedValues[locale.languageCode]?['termsOfService'] ??
      en['termsOfService']!;
  String get chinese =>
      _localizedValues[locale.languageCode]?['chinese'] ?? en['chinese']!;
  String get english =>
      _localizedValues[locale.languageCode]?['english'] ?? en['english']!;

  String get appTitle =>
      _localizedValues[locale.languageCode]?['appTitle'] ?? en['appTitle']!;
  String get startButton =>
      _localizedValues[locale.languageCode]?['startButton'] ??
      en['startButton']!;
  String get pauseButton =>
      _localizedValues[locale.languageCode]?['pauseButton'] ??
      en['pauseButton']!;
  String get resetButton =>
      _localizedValues[locale.languageCode]?['resetButton'] ??
      en['resetButton']!;
  String get skipButton =>
      _localizedValues[locale.languageCode]?['skipButton'] ?? en['skipButton']!;
  String get settingsButton =>
      _localizedValues[locale.languageCode]?['settingsButton'] ??
      en['settingsButton']!;
  String get historyButton =>
      _localizedValues[locale.languageCode]?['historyButton'] ??
      en['historyButton']!;
  String get aboutButton =>
      _localizedValues[locale.languageCode]?['aboutButton'] ??
      en['aboutButton']!;

  String get workSession =>
      _localizedValues[locale.languageCode]?['workSession'] ??
      en['workSession']!;
  String get shortBreak =>
      _localizedValues[locale.languageCode]?['shortBreak'] ?? en['shortBreak']!;
  String get longBreak =>
      _localizedValues[locale.languageCode]?['longBreak'] ?? en['longBreak']!;

  String get settingsTitle =>
      _localizedValues[locale.languageCode]?['settingsTitle'] ??
      en['settingsTitle']!;
  String get timerSettings =>
      _localizedValues[locale.languageCode]?['timerSettings'] ??
      en['timerSettings']!;
  String get workDuration =>
      _localizedValues[locale.languageCode]?['workDuration'] ??
      en['workDuration']!;
  String get shortBreakDuration =>
      _localizedValues[locale.languageCode]?['shortBreakDuration'] ??
      en['shortBreakDuration']!;
  String get longBreakDuration =>
      _localizedValues[locale.languageCode]?['longBreakDuration'] ??
      en['longBreakDuration']!;
  String get sessionsBeforeLongBreak =>
      _localizedValues[locale.languageCode]?['sessionsBeforeLongBreak'] ??
      en['sessionsBeforeLongBreak']!;

  String get notificationSettings =>
      _localizedValues[locale.languageCode]?['notificationSettings'] ??
      en['notificationSettings']!;
  String get displaySettings =>
      _localizedValues[locale.languageCode]?['displaySettings'] ??
      en['displaySettings']!;
  String get appInfo =>
      _localizedValues[locale.languageCode]?['appInfo'] ?? en['appInfo']!;

  String get historyTitle =>
      _localizedValues[locale.languageCode]?['historyTitle'] ??
      en['historyTitle']!;
  String get aboutTitle =>
      _localizedValues[locale.languageCode]?['aboutTitle'] ?? en['aboutTitle']!;
  String get noHistoryMessage =>
      _localizedValues[locale.languageCode]?['noHistoryMessage'] ??
      en['noHistoryMessage']!;
  String get clearHistory =>
      _localizedValues[locale.languageCode]?['clearHistory'] ??
      en['clearHistory']!;

  String get minutes =>
      _localizedValues[locale.languageCode]?['minutes'] ?? en['minutes']!;
  String get seconds =>
      _localizedValues[locale.languageCode]?['seconds'] ?? en['seconds']!;
  String get sessions =>
      _localizedValues[locale.languageCode]?['sessions'] ?? en['sessions']!;
  String get actualDuration =>
      _localizedValues[locale.languageCode]?['actualDuration'] ??
      en['actualDuration']!;

  String get sessionCompleted =>
      _localizedValues[locale.languageCode]?['sessionCompleted'] ??
      en['sessionCompleted']!;
  String get breakCompleted =>
      _localizedValues[locale.languageCode]?['breakCompleted'] ??
      en['breakCompleted']!;

  String get workSessionCompleted =>
      _localizedValues[locale.languageCode]?['workSessionCompleted'] ??
      en['workSessionCompleted']!;

  String get shortBreakCompleted =>
      _localizedValues[locale.languageCode]?['shortBreakCompleted'] ??
      en['shortBreakCompleted']!;

  String get longBreakCompleted =>
      _localizedValues[locale.languageCode]?['longBreakCompleted'] ??
      en['longBreakCompleted']!;

  String get cancel =>
      _localizedValues[locale.languageCode]?['cancel'] ?? en['cancel']!;
  String get save =>
      _localizedValues[locale.languageCode]?['save'] ?? en['save']!;

  String get systemDefault =>
      _localizedValues[locale.languageCode]?['systemDefault'] ??
      en['systemDefault']!;

  // About page
  String get appVersion =>
      _localizedValues[locale.languageCode]?['appVersion'] ?? en['appVersion']!;
  String get appDescription =>
      _localizedValues[locale.languageCode]?['appDescription'] ??
      en['appDescription']!;
  String get developerInfo =>
      _localizedValues[locale.languageCode]?['developerInfo'] ??
      en['developerInfo']!;
  String get developerName =>
      _localizedValues[locale.languageCode]?['developerName'] ??
      en['developerName']!;
  String get developerEmail =>
      _localizedValues[locale.languageCode]?['developerEmail'] ??
      en['developerEmail']!;
  String get contactDeveloper =>
      _localizedValues[locale.languageCode]?['contactDeveloper'] ??
      en['contactDeveloper']!;
  String get appFeatures =>
      _localizedValues[locale.languageCode]?['appFeatures'] ??
      en['appFeatures']!;
  String get feature1 =>
      _localizedValues[locale.languageCode]?['feature1'] ?? en['feature1']!;
  String get feature2 =>
      _localizedValues[locale.languageCode]?['feature2'] ?? en['feature2']!;
  String get feature3 =>
      _localizedValues[locale.languageCode]?['feature3'] ?? en['feature3']!;
  String get feature4 =>
      _localizedValues[locale.languageCode]?['feature4'] ?? en['feature4']!;
  String get feature5 =>
      _localizedValues[locale.languageCode]?['feature5'] ?? en['feature5']!;
  String get feature6 =>
      _localizedValues[locale.languageCode]?['feature6'] ?? en['feature6']!;
  String get feature7 =>
      _localizedValues[locale.languageCode]?['feature7'] ?? en['feature7']!;
  String get feature8 =>
      _localizedValues[locale.languageCode]?['feature8'] ?? en['feature8']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
