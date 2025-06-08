import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:tomato_app/models/settings.dart';
import 'package:tomato_app/models/timer.dart';
import 'package:tomato_app/providers/timer_provider.dart';
import 'package:tomato_app/screens/splash_screen.dart';
import 'package:tomato_app/utils/l10n/app_localizations.dart';
import 'package:tomato_app/utils/routes.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidWebViewPlatform.registerWith();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      WebKitWebViewPlatform.registerWith();
    }
  }

  const settings = Settings(
    isDarkMode: false,
    notificationsEnabled: true,
    vibrationEnabled: true,
    keepScreenOn: true,
    locale: 'zh',
    soundEnabled: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingsModel(settings: settings),
        ),
        ChangeNotifierProxyProvider<SettingsModel, TimerModel>(
          create: (context) => TimerModel(
            settings:
                Provider.of<SettingsModel>(context, listen: false).settings,
          ),
          update: (context, settingsModel, timerModel) =>
              timerModel ??
              TimerModel(
                settings: settingsModel.settings,
              ),
        ),
        ChangeNotifierProxyProvider2<TimerModel, SettingsModel, TimerProvider>(
          create: (context) => TimerProvider(
            timerModel: Provider.of<TimerModel>(context, listen: false),
            settings:
                Provider.of<SettingsModel>(context, listen: false).settings,
          ),
          update: (context, timerModel, settingsModel, timerProvider) =>
              timerProvider ??
              TimerProvider(
                timerModel: timerModel,
                settings: settingsModel.settings,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsModel, child) {
        return MaterialApp(
          title: '番茄时钟',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE57373),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE57373),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsModel.settings.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
          locale: settingsModel.settings.locale == 'zh'
              ? const Locale('zh', 'CN')
              : const Locale('en', 'US'),
          home: const SplashScreen(),
          routes: Routes.routes,
        );
      },
    );
  }
}

if (await Vibration.hasVibrator() ?? false) {
  Vibration.vibrate();
}
