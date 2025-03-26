import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../models/timer_model.dart';
import '../utils/app_theme.dart';
import '../utils/l10n/app_localizations.dart';
import '../widgets/control_buttons.dart';
import '../widgets/glassmorphic_background.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/timer_display.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  TimerState? _lastState;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final timerModel = Provider.of<TimerModel>(context);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 检测计时器完成状态变化
    if (_lastState != timerModel.state &&
        timerModel.state == TimerState.finished) {
      // 震动提醒
      Vibration.vibrate(duration: 1000);

      // 延迟一下，让界面先渲染完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final message =
            timerModel.currentType == TimerType.work
                ? (timerModel.currentSession >=
                        timerModel.sessionsBeforeLongBreak
                    ? localizations.longBreakCompleted
                    : localizations.shortBreakCompleted)
                : localizations.workSessionCompleted;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: GlassmorphicContainer(
              width: double.infinity,
              height: 60,
              borderRadius: 12,
              blur: 10,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDarkMode
                        ? [
                          AppTheme.darkGlassColor.withOpacity(0.3),
                          AppTheme.darkGlassColor.withOpacity(0.4),
                        ]
                        : [
                          AppTheme.lightGlassColor.withOpacity(0.8),
                          AppTheme.lightGlassColor.withOpacity(0.9),
                        ],
              ),
              borderColor:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.6),
              shadowColor: Colors.transparent,
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            elevation: 0,
          ),
        );
      });
    }
    _lastState = timerModel.state;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: GlassmorphicContainer(
          width: 200,
          height: 48,
          borderRadius: 24,
          blur: 10,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      AppTheme.darkGlassColor.withOpacity(0.1),
                      AppTheme.darkGlassColor.withOpacity(0.2),
                    ]
                    : [
                      AppTheme.lightGlassColor.withOpacity(0.6),
                      AppTheme.lightGlassColor.withOpacity(0.7),
                    ],
          ),
          borderColor:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
          shadowColor: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.av_timer,
                color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.appTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GlassmorphicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(child: TimerDisplay(timerModel: timerModel)),
                ControlButtons(timerModel: timerModel),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? AppTheme.darkGlassColor.withOpacity(0.2)
                    : AppTheme.lightGlassColor.withOpacity(0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.6),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.history,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  label: Text(
                    localizations.historyButton,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  label: Text(
                    localizations.settingsButton,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
