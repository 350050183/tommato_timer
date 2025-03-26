import 'package:flutter/material.dart';

import '../models/timer_model.dart';
import '../utils/app_theme.dart';
import '../utils/l10n/app_localizations.dart';
import 'glassmorphic_container.dart';

class TimerDisplay extends StatelessWidget {
  final TimerModel timerModel;

  const TimerDisplay({super.key, required this.timerModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final containerSize = size.width * 0.8 < 300 ? size.width * 0.8 : 300.0;

    String timerTypeText;
    Color progressColor;

    switch (timerModel.currentType) {
      case TimerType.work:
        timerTypeText = localizations.workSession;
        progressColor = AppTheme.primaryColor;
        break;
      case TimerType.shortBreak:
        timerTypeText = localizations.shortBreak;
        progressColor = AppTheme.secondaryColor;
        break;
      case TimerType.longBreak:
        timerTypeText = localizations.longBreak;
        progressColor = AppTheme.accentColor;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 计时器类型指示
          GlassmorphicContainer(
            width: 200,
            height: 45,
            borderRadius: 22.5,
            blur: 10,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppTheme.darkGlassColor.withOpacity(0.1),
                      AppTheme.darkGlassColor.withOpacity(0.2),
                    ]
                  : [
                      AppTheme.lightGlassColor.withOpacity(0.6),
                      AppTheme.lightGlassColor.withOpacity(0.7),
                    ],
            ),
            borderColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.5),
            shadowColor: Colors.transparent,
            child: Center(
              child: Text(
                timerTypeText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // 计时器主体
          GlassmorphicContainer(
            width: containerSize,
            height: containerSize,
            shape: BoxShape.circle,
            blur: 10,
            border: 1.5,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppTheme.darkGlassColor.withOpacity(0.1),
                      AppTheme.darkGlassColor.withOpacity(0.2),
                    ]
                  : [
                      AppTheme.lightGlassColor.withOpacity(0.6),
                      AppTheme.lightGlassColor.withOpacity(0.7),
                    ],
            ),
            borderColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.5),
            shadowColor: isDarkMode 
                ? Colors.black.withOpacity(0.1) 
                : Colors.black.withOpacity(0.2),
            shadowBlur: 15,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 进度指示器
                SizedBox(
                  width: containerSize * 0.9,
                  height: containerSize * 0.9,
                  child: CircularProgressIndicator(
                    value: timerModel.progress,
                    strokeWidth: 12,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    backgroundColor: isDarkMode 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey.shade200,
                  ),
                ),
                // 时间文本
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDuration(timerModel.remainingTime),
                      style: TextStyle(
                        fontSize: containerSize * 0.2,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${timerModel.currentSession}/${timerModel.sessionsBeforeLongBreak}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 会话计数器
          GlassmorphicContainer(
            width: 200,
            height: 40,
            borderRadius: 20,
            blur: 10,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      AppTheme.darkGlassColor.withOpacity(0.1),
                      AppTheme.darkGlassColor.withOpacity(0.2),
                    ]
                  : [
                      AppTheme.lightGlassColor.withOpacity(0.6),
                      AppTheme.lightGlassColor.withOpacity(0.7),
                    ],
            ),
            borderColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.5),
            shadowColor: Colors.transparent,
            child: Center(
              child: Text(
                '${localizations.workSession} ${timerModel.currentSession}/${timerModel.sessionsBeforeLongBreak}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
