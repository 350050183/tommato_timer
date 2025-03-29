import 'package:flutter/material.dart';

import '../models/timer_model.dart';
import '../utils/app_theme.dart';
import '../utils/l10n/app_localizations.dart';
import 'glassmorphic_container.dart';
import 'tomato_3d_model.dart';

class TimerDisplay extends StatelessWidget {
  final TimerModel timerModel;

  const TimerDisplay({super.key, required this.timerModel});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

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
          const SizedBox(height: 20),
          // 3D 模型
          Tomato3DModel(progress: timerModel.progress, isDarkMode: isDarkMode),
          const SizedBox(height: 20),
          // 时间文本
          Text(
            _formatDuration(timerModel.remainingTime),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // 会话计数器
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
