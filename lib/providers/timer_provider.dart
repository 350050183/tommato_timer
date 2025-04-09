import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/settings.dart';
import '../models/timer.dart';

class TimerProvider extends ChangeNotifier {
  final TimerModel _timerModel;
  final Settings _settings;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _tickTimer;
  bool _isSoundLoaded = false;
  bool _isCompleted = false;

  TimerProvider({
    required TimerModel timerModel,
    required Settings settings,
  })  : _timerModel = timerModel,
        _settings = settings {
    _loadSound();
    _timerModel.addListener(_onTimerChanged);
  }

  TimerModel get timerModel => _timerModel;
  Settings get settings => _settings;
  bool get isCompleted => _isCompleted;

  bool get isRunning => _timerModel.isRunning;
  Duration get remainingTime => _timerModel.remainingTime;
  double get progress => _timerModel.progress;
  String get displayTime {
    final duration = _timerModel.remainingTime;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _onTimerChanged() {
    debugPrint('TimerProvider: 计时器状态变化');
    if (_timerModel.state == TimerState.finished && !_isCompleted) {
      _isCompleted = true;
      if (_settings.notificationsEnabled) {
        debugPrint('TimerProvider: 计时器完成，准备播放声音');
        _playCompletionSound();
      }
      resetTimer();
    } else if (_timerModel.state != TimerState.finished) {
      _isCompleted = false;
    }
    notifyListeners();
  }

  Future<void> _loadSound() async {
    try {
      debugPrint('TimerProvider: 开始加载声音文件');
      AudioLogger.logLevel = AudioLogLevel.info;
      debugPrint('TimerProvider: 设置AudioPlayer日志级别为info');
      await _audioPlayer.setSource(AssetSource('sounds/complete.mp3'));
      _isSoundLoaded = true;
      debugPrint('TimerProvider: 声音文件加载成功');
    } catch (e) {
      debugPrint('TimerProvider: 加载声音文件失败: $e');
    }
  }

  void startTimer() {
    if (_tickTimer != null) return;

    debugPrint('TimerProvider: 开始计时');
    _timerModel.startTimer();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint('TimerProvider: tick, 当前时间: ${DateTime.now()}');
      _timerModel.tick();
    });
    notifyListeners();
  }

  void pauseTimer() {
    debugPrint('TimerProvider: 暂停计时');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.pauseTimer();
    notifyListeners();
  }

  void resetTimer() {
    debugPrint('TimerProvider: 重置计时器');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.reset();
    notifyListeners();
  }

  void skipToNext() {
    debugPrint('TimerProvider: 跳到下一个');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.skipToNext();
    notifyListeners();
  }

  void handleCubeRotation() {
    debugPrint('TimerProvider: 处理3D旋转');
    if (_timerModel.isRunning) {
      debugPrint('TimerProvider: 计时器正在运行，保持运行状态');
      return;
    }
  }

  void setSelectedDuration(int minutes) {
    debugPrint('TimerProvider: 设置选择的时间: $minutes 分钟');
    if (!_timerModel.isRunning) {
      _timerModel.setSelectedDuration(minutes);
      notifyListeners();
    } else {
      debugPrint('TimerProvider: 计时器运行中，忽略时间设置');
    }
  }

  Future<void> _playCompletionSound() async {
    debugPrint('TimerProvider: 开始播放声音');
    if (!_isSoundLoaded) {
      debugPrint('TimerProvider: 声音文件未加载，开始加载');
      await _loadSound();
    }
    try {
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
      debugPrint('TimerProvider: 声音播放成功');
    } catch (e) {
      debugPrint('TimerProvider: 播放声音失败: $e');
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _timerModel.removeListener(_onTimerChanged);
    _audioPlayer.dispose();
    super.dispose();
  }
}
