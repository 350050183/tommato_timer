import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/l10n/app_localizations.dart';
import '../widgets/glassmorphic_container.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _contactDeveloper(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'swingcoder@gmail.com',
      queryParameters: {'subject': localizations.contactDeveloper},
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: GlassmorphicContainer(
                width: double.infinity,
                height: 60,
                borderRadius: 12,
                blur: 10,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.4),
                          ]
                          : [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.9),
                          ],
                ),
                borderColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.6),
                shadowColor: Colors.transparent,
                child: Center(
                  child: Text(
                    localizations.feedbackEmailError,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              elevation: 0,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.feedbackEmailError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.aboutTitle), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // 番茄时钟 App Logo
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFF44336), Color(0xFFE53935)],
                    center: Alignment(0.1, 0.1),
                    focal: Alignment(0.1, 0.1),
                    radius: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 番茄表面纹理
                    Positioned.fill(
                      child: CustomPaint(painter: TomatoTexturePainter()),
                    ),
                    // 计时刻度
                    Positioned.fill(
                      child: CustomPaint(painter: TimerMarksPainter()),
                    ),
                    // 番茄顶部绿叶
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43A047),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 左侧叶片
                    Positioned(
                      top: 20,
                      left: 60,
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Container(
                          width: 22,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43A047),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 右侧叶片
                    Positioned(
                      top: 20,
                      right: 60,
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Container(
                          width: 22,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43A047),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 中间白色圆圈
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                    // 计时指针
                    Center(
                      child: Transform.rotate(
                        angle: 0.8,
                        child: Container(
                          width: 5,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 中央圆点
                    Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.av_timer, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    localizations.appTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('版本 1.0.0', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text(
                '一个简单的番茄工作法时间管理应用。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              const Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '番茄工作法是什么？',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '番茄工作法是一种时间管理方法，它使用一个定时器来分割工作，传统上是25分钟的工作时间，然后是5分钟的休息时间。'
                        '这些间隔被称为"番茄"，每完成四个番茄后，会有一个较长的休息时间（通常为15-30分钟）。',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 开发者信息卡片
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.developer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: Text(localizations.developerEmail),
                        subtitle: const Text('swingcoder@gmail.com'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _contactDeveloper(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// 番茄纹理绘制
class TomatoTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // 绘制一些随机的圆点作为番茄纹理
    for (int i = 0; i < 30; i++) {
      final angle = i * 0.2;
      final x = center.dx + radius * 0.7 * math.cos(angle);
      final y = center.dy + radius * 0.7 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 计时器刻度绘制
class TimerMarksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // 外圆
    canvas.drawCircle(center, radius - 8, paint);

    // 刻度
    paint.strokeWidth = 1.5;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final startX = center.dx + (radius - 12) * math.cos(angle);
      final startY = center.dy + (radius - 12) * math.sin(angle);
      final endX = center.dx + (radius - 8) * math.cos(angle);
      final endY = center.dy + (radius - 8) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // 小刻度
    paint.strokeWidth = 1;
    for (int i = 0; i < 60; i++) {
      // 跳过已经画过的主刻度
      if (i % 5 == 0) continue;

      final angle = i * math.pi / 30;
      final startX = center.dx + (radius - 10) * math.cos(angle);
      final startY = center.dy + (radius - 10) * math.sin(angle);
      final endX = center.dx + (radius - 8) * math.cos(angle);
      final endY = center.dy + (radius - 8) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
