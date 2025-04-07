import 'dart:ui';

import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final double border;
  final LinearGradient linearGradient;
  final Color borderColor;
  final Color shadowColor;
  final EdgeInsetsGeometry? padding;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 20,
    this.blur = 20,
    this.border = 2,
    required this.linearGradient,
    required this.borderColor,
    required this.shadowColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: blur, spreadRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: linearGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: border),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
