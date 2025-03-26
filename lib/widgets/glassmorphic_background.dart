import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class GlassmorphicBackground extends StatelessWidget {
  final Widget child;
  final bool useScaffoldBackground;

  const GlassmorphicBackground({
    super.key,
    required this.child,
    this.useScaffoldBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkMode
                  ? [
                    AppTheme.darkBackgroundColor,
                    Color.lerp(
                      AppTheme.darkBackgroundColor,
                      AppTheme.primaryColor,
                      0.1,
                    )!,
                  ]
                  : [
                    AppTheme.lightBackgroundColor,
                    Color.lerp(
                      AppTheme.lightBackgroundColor,
                      AppTheme.primaryColor,
                      0.1,
                    )!,
                  ],
        ),
      ),
      child: Stack(
        children: [
          // 渐变装饰元素
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(
                  isDarkMode ? 0.1 : 0.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withOpacity(
                  isDarkMode ? 0.1 : 0.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // 内容
          child,
        ],
      ),
    );
  }
}
