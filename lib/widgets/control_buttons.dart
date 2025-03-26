import 'package:flutter/material.dart';

import '../models/timer_model.dart';
import '../utils/app_theme.dart';
import '../utils/l10n/app_localizations.dart';
import 'glassmorphic_container.dart';

class ControlButtons extends StatelessWidget {
  final TimerModel timerModel;

  const ControlButtons({super.key, required this.timerModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRunning = timerModel.state == TimerState.running;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 根据当前计时器类型获取下一个计时器类型的文本
    String nextTimerText;
    Color nextTimerColor;
    if (timerModel.currentType == TimerType.work) {
      // 工作阶段后是休息
      if (timerModel.currentSession >= timerModel.sessionsBeforeLongBreak) {
        nextTimerText = localizations.longBreak;
        nextTimerColor = AppTheme.accentColor;
      } else {
        nextTimerText = localizations.shortBreak;
        nextTimerColor = AppTheme.secondaryColor;
      }
    } else {
      // 休息后是工作
      nextTimerText = localizations.workSession;
      nextTimerColor = AppTheme.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _glassmorphicButton(
                context: context,
                onPressed:
                    isRunning ? timerModel.pauseTimer : timerModel.startTimer,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRunning
                          ? localizations.pauseButton
                          : localizations.startButton,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _glassmorphicButton(
                context: context,
                onPressed: timerModel.resetTimer,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.resetButton,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _glassmorphicButton(
            context: context,
            width: 240,
            onPressed: timerModel.skipToNext,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                nextTimerColor.withOpacity(isDarkMode ? 0.1 : 0.1),
                nextTimerColor.withOpacity(isDarkMode ? 0.2 : 0.2),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${localizations.skipButton}: $nextTimerText",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.skip_next,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassmorphicButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    double width = 150,
    LinearGradient? linearGradient,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GlassmorphicContainer(
      width: width,
      height: 48,
      borderRadius: 24,
      blur: 10,
      border: 1,
      linearGradient:
          linearGradient ??
          LinearGradient(
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
      shadowColor:
          isDarkMode
              ? Colors.black.withOpacity(0.1)
              : Colors.black.withOpacity(0.2),
      shadowBlur: 5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Center(child: child),
        ),
      ),
    );
  }
}
