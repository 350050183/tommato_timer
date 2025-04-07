import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class GlassmorphicBackground extends StatelessWidget {
  final Widget child;
  final bool useGradient;
  final List<Color>? gradientColors;

  const GlassmorphicBackground({
    super.key,
    required this.child,
    this.useGradient = true,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient:
            useGradient
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      gradientColors ??
                      (isDarkMode
                          ? [
                            const Color(0xFF1A1A1A),
                            Color.lerp(
                              const Color(0xFF1A1A1A),
                              AppTheme.primaryColor,
                              0.1,
                            )!,
                          ]
                          : [
                            const Color(0xFFF5F5F5),
                            Color.lerp(
                              const Color(0xFFF5F5F5),
                              AppTheme.primaryColor,
                              0.1,
                            )!,
                          ]),
                )
                : null,
        color:
            useGradient
                ? null
                : (isDarkMode
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF5F5F5)),
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
