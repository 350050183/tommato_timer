import 'dart:ui';

import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final double border;
  final Color shadowColor;
  final Offset shadowOffset;
  final double shadowBlur;
  final LinearGradient linearGradient;
  final BoxShape shape;
  final BorderRadius? customBorderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 20.0,
    this.blur = 10.0,
    this.borderColor = Colors.white30,
    this.border = 1.0,
    this.shadowColor = Colors.black26,
    this.shadowOffset = const Offset(0, 5),
    this.shadowBlur = 10.0,
    this.linearGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFffffff), Color(0xB0ffffff)],
      stops: [0.0, 1.0],
    ),
    this.shape = BoxShape.rectangle,
    this.customBorderRadius,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // 根据亮暗模式调整默认属性
    final effectiveGradient =
        isDarkMode
            ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x40FFFFFF), Color(0x20FFFFFF)],
              stops: [0.0, 1.0],
            )
            : linearGradient;

    final effectiveBorderColor = isDarkMode ? Colors.white10 : borderColor;

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius:
            shape == BoxShape.rectangle
                ? customBorderRadius ?? BorderRadius.circular(borderRadius)
                : null,
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            shape == BoxShape.rectangle
                ? customBorderRadius ?? BorderRadius.circular(borderRadius)
                : BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              shape: shape,
              borderRadius:
                  shape == BoxShape.rectangle
                      ? customBorderRadius ??
                          BorderRadius.circular(borderRadius)
                      : null,
              border: Border.all(color: effectiveBorderColor, width: border),
              gradient: effectiveGradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
