import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:vibration/vibration.dart';

import '../models/settings.dart';
import '../models/timer_model.dart';
import '../utils/app_theme.dart';
import '../utils/l10n/app_localizations.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_display.dart';

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
    final settingsModel = Provider.of<SettingsModel>(context);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = settingsModel.isDarkMode;

    // 检测计时器完成状态变化
    if (_lastState != timerModel.state &&
        timerModel.state == TimerState.finished) {
      // 震动提醒
      // Vibration.vibrate(duration: 1000);

      // 延迟一下，让界面先渲染完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final message =
            timerModel.currentType == TimerType.work
                ? (timerModel.currentSession >= timerModel.longBreakInterval
                    ? localizations?.longBreakCompleted
                    : localizations?.shortBreakCompleted)
                : localizations?.workSessionCompleted;

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
                  message??'结束',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      AppTheme.darkBackgroundColor,
                      AppTheme.darkBackgroundColor.withOpacity(0.8),
                    ]
                    : [
                      AppTheme.lightBackgroundColor,
                      AppTheme.lightBackgroundColor.withOpacity(0.8),
                    ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部状态栏
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 设置按钮
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    // 历史记录按钮
                    IconButton(
                      icon: Icon(
                        Icons.history,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/history');
                      },
                    ),
                  ],
                ),
              ),
              // 主要内容
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 3D模型和时间显示
                    const Expanded(child: TimerDisplay(remainingTime: Duration(seconds: 15*60),isRunning: false)),
                    // 控制按钮
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TimerControls(
                        isRunning: timerModel.isRunning,
                        onStart: () {
                          timerModel.startTimer();
                        },
                        onStop: () {
                          timerModel.pauseTimer();
                        },
                        onReset: () {
                          timerModel.reset();
                        },
                        onSkip: () {
                          timerModel.skipToNext();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
