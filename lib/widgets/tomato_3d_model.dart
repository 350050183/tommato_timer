import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Tomato3DModel extends StatefulWidget {
  final double progress;
  final bool isDarkMode;

  const Tomato3DModel({
    super.key,
    required this.progress,
    required this.isDarkMode,
  });

  @override
  State<Tomato3DModel> createState() => _Tomato3DModelState();
}

class _Tomato3DModelState extends State<Tomato3DModel> {
  @override
  Widget build(BuildContext context) {
    debugPrint('Building Tomato3DModel');
    return SizedBox(
      width: 300,
      height: 300,
      child: ModelViewer(
        backgroundColor:
            widget.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
        src: 'assets/cube/tomato-timer.glb',
        alt: '番茄计时器',
        ar: false,
        arModes: const ['scene-viewer', 'webxr', 'quick-look'],
        autoRotate: true,
        cameraControls: true,
        disableZoom: true,
        loading: Loading.eager,
        autoPlay: true,
        fieldOfView: '30deg',
        exposure: 1.0,
        shadowIntensity: 1,
        shadowSoftness: 1,
        environmentImage: 'neutral',
      ),
    );
  }
}
