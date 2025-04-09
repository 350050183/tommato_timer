import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TimerProgressIndicator extends StatelessWidget {
  final double progress;

  const TimerProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: isDarkMode ? Colors.white12 : Colors.black12,
      valueColor: AlwaysStoppedAnimation<Color>(
        isDarkMode
            ? AppTheme.primaryColor.withOpacity(0.8)
            : AppTheme.primaryColor,
      ),
    );
  }
}
