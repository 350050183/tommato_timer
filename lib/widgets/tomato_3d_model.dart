import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Tomato3DModel extends StatefulWidget {
  final int currentSide;
  final Function(int) onSideChanged;

  const Tomato3DModel({
    super.key,
    required this.currentSide,
    required this.onSideChanged,
  });

  @override
  State<Tomato3DModel> createState() => _Tomato3DModelState();
}

class _Tomato3DModelState extends State<Tomato3DModel> {
  String _getCameraOrbit() {
    switch (widget.currentSide) {
      case 0:
        return '0deg 75deg 75%'; // 正面
      case 1:
        return '90deg 75deg 75%'; // 右面
      case 2:
        return '180deg 75deg 75%'; // 背面
      case 3:
        return '270deg 75deg 75%'; // 左面
      default:
        return '0deg 75deg 75%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: 'assets/models/tomato.glb',
      alt: '番茄计时器',
      ar: false,
      autoRotate: true,
      cameraControls: true,
      disableZoom: true,
      disablePan: false,
      disableTap: false,
      cameraOrbit: _getCameraOrbit(),
      minCameraOrbit: 'auto auto 75%',
      maxCameraOrbit: 'auto auto 75%',
      orientation: '0deg 0deg 0deg',
      scale: '1 1 1',
      rotationPerSecond: '30deg',
      interpolationDecay: 200,
      backgroundColor: const Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
    );
  }
}
