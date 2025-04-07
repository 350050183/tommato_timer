import 'package:flutter/material.dart';

import '../screens/about_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> get routes => {
    '/settings': (context) => const SettingsScreen(),
    '/history': (context) => const HistoryScreen(),
    '/about': (context) => const AboutScreen(),
  };
}
