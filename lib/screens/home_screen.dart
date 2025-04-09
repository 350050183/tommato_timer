import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tomato_app/utils/l10n/app_localizations.dart';

import '../providers/timer_provider.dart';
import '../widgets/control_buttons.dart';
import '../widgets/glassmorphic_background.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/three_d_cube.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_progress_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GlassmorphicContainer(
          width: 180,
          height: 48,
          borderRadius: 24,
          blur: 10,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.4),
                  ],
          ),
          borderColor: isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.5),
          shadowColor: isDarkMode
              ? Colors.black.withOpacity(0.5)
              : Colors.black.withOpacity(0.2),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GlassmorphicContainer(
              width: 48,
              height: 48,
              borderRadius: 24,
              blur: 10,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.4),
                      ],
              ),
              borderColor: isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.5),
              shadowColor: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.2),
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ),
          ),
        ],
      ),
      body: GlassmorphicBackground(
        child: Consumer<TimerProvider>(
          builder: (context, timerProvider, child) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D立方体选择器
                  GlassmorphicContainer(
                    width: 300,
                    height: 300,
                    borderRadius: 20,
                    blur: 10,
                    border: 1.5,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.white.withOpacity(0.4),
                            ],
                    ),
                    borderColor: isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    shadowColor: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.2),
                    child: ThreeDCube(
                      onDurationSelected: (duration) {
                        timerProvider.setSelectedDuration(duration);
                      },
                      onRotationChanged: (x, y, z) {
                        timerProvider.handleCubeRotation();
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 计时器显示
                  GlassmorphicContainer(
                    width: 200,
                    height: 80,
                    borderRadius: 20,
                    blur: 10,
                    border: 1.5,
                    linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ]
                          : [
                              Colors.white.withOpacity(0.7),
                              Colors.white.withOpacity(0.4),
                            ],
                    ),
                    borderColor: isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    shadowColor: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.2),
                    child: TimerDisplay(
                      remainingTime: timerProvider.remainingTime,
                      isRunning: timerProvider.isRunning,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 进度条
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TimerProgressIndicator(
                      progress: timerProvider.progress,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // 控制按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ControlButtons(
                      isRunning: timerProvider.isRunning,
                      onStart: timerProvider.startTimer,
                      onPause: timerProvider.pauseTimer,
                      onReset: timerProvider.resetTimer,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleCubeRotation() {
    // 删除这个日志（如果存在）
    // debugPrint('HomeScreen: 处理3D旋转');
    // ... 其他代码
  }
}
