import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 重置按钮
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onReset,
          color: AppTheme.primaryColor,
        ),
        // 开始/停止按钮
        IconButton(
          icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
          onPressed: isRunning ? onStop : onStart,
          color: AppTheme.primaryColor,
        ),
        // 跳过按钮
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: onSkip,
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
