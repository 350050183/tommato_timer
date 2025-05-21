import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // Import WidgetsBindingObserver

import '../models/settings.dart';
import '../models/timer.dart';
import '../services/notification_service.dart'; // Import NotificationService

class TimerProvider extends ChangeNotifier with WidgetsBindingObserver { // Add mixin
  final TimerModel _timerModel;
  final Settings _settings;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final NotificationService _notificationService = NotificationService(); // Initialize NotificationService
  Timer? _tickTimer;
  bool _isSoundLoaded = false;
  bool _isCompleted = false;
  DateTime? _scheduledEndTime; // Add _scheduledEndTime field
  static const int _backgroundNotificationId = 123; // Add _backgroundNotificationId field

  TimerProvider({
    required TimerModel timerModel,
    required Settings settings,
  })  : _timerModel = timerModel,
        _settings = settings {
    _loadSound();
    _timerModel.addListener(_onTimerChanged);
    WidgetsBinding.instance.addObserver(this); // Initialize observer
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
    // debugPrint('TimerProvider: 计时器状态变化');
    if (_timerModel.state == TimerState.finished && !_isCompleted) {
      _isCompleted = true;
      if (_settings.notificationsEnabled) {
        // debugPrint('TimerProvider: 计时器完成，准备播放声音');
        _playCompletionSound();
      }
      _tickTimer?.cancel();
      _tickTimer = null;
    } else if (_timerModel.state != TimerState.finished) {
      _isCompleted = false;
    }
    notifyListeners();
  }

  Future<void> _loadSound() async {
    // debugPrint('TimerProvider: 开始加载声音文件');
    // debugPrint('TimerProvider: 设置AudioPlayer日志级别为info');
    try {
      await _audioPlayer.setSource(AssetSource('sounds/complete.mp3'));
      _isSoundLoaded = true;
      // debugPrint('TimerProvider: 声音文件加载成功');
    } catch (e) {
      // debugPrint('TimerProvider: 加载声音文件失败: $e');
    }
  }

  void startTimer() {
    if (_tickTimer != null) {
      // debugPrint('TimerProvider: 计时器已经在运行');
      return;
    }

    if (_isCompleted) {
      // debugPrint('TimerProvider: 重置已完成的计时器');
      resetTimer();
    }

    // debugPrint('TimerProvider: 开始计时');
    _timerModel.startTimer();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // debugPrint('TimerProvider: tick, 当前时间: ${DateTime.now()}');
      _timerModel.tick();
    });
    notifyListeners();
  }

  void pauseTimer() {
    // debugPrint('TimerProvider: 暂停计时');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.pauseTimer();
    notifyListeners();
  }

  void resetTimer() {
    // debugPrint('TimerProvider: 重置计时器');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.reset();
    notifyListeners();
  }

  void skipToNext() {
    // debugPrint('TimerProvider: 跳到下一个');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.skipToNext();
    notifyListeners();
  }

  void handleCubeRotation() {
    // debugPrint('TimerProvider: 处理3D旋转');
    if (_timerModel.isRunning) {
      // debugPrint('TimerProvider: 计时器正在运行，保持运行状态');
      return;
    }
  }

  void setSelectedDuration(int minutes) {
    // debugPrint('TimerProvider: 设置选择的时间: $minutes 分钟');
    if (!_timerModel.isRunning) {
      _timerModel.setSelectedDuration(minutes);
      _isCompleted = false;
      notifyListeners();
    } else {
      // debugPrint('TimerProvider: 计时器运行中，忽略时间设置');
    }
  }

  Future<void> _playCompletionSound() async {
    // debugPrint('TimerProvider: 开始播放声音');
    if (!_isSoundLoaded) {
      // debugPrint('TimerProvider: 声音文件未加载，开始加载');
      await _loadSound();
    }
    try {
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
      // debugPrint('TimerProvider: 声音播放成功');
    } catch (e) {
      // debugPrint('TimerProvider: 播放声音失败: $e');
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _timerModel.removeListener(_onTimerChanged);
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this); // Dispose observer
    super.dispose();
  }

  // Override didChangeAppLifecycleState
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print("App Resumed");
        _notificationService.cancelNotification(_backgroundNotificationId);

        if (_scheduledEndTime != null) {
          final DateTime now = DateTime.now();
          if (now.isAfter(_scheduledEndTime!) || now.isAtSameMomentAs(_scheduledEndTime!)) {
            // Timer finished while backgrounded
            print("Timer finished in background. Skipping to next.");
            // Ensure the timer model knows its time is up before skipping.
            _timerModel.setRemainingTime(Duration.zero); // Set to zero
            skipToNext(); // This calls _timerModel.skipToNext() and handles _tickTimer and notifyListeners
          } else {
            // Timer still running
            final Duration remainingDuration = _scheduledEndTime!.difference(now);
            print("Timer resuming with remaining: $remainingDuration");
            _timerModel.setRemainingTime(remainingDuration);
            // We need to make sure the timer model is in a running state
            // if it wasn't already, and that TimerProvider's _tickTimer is active.
            // Call startTimer() which handles _timerModel.startTimer() and _tickTimer.
            // _timerModel.startTimer(); // Make sure model knows it's running
            startTimer(); // This will setup the _tickTimer and call _timerModel.startTimer()
          }
          _scheduledEndTime = null;
        }
        // notifyListeners(); // Might be needed if not all paths above trigger it.
                           // startTimer() and skipToNext() in TimerProvider call notifyListeners().
                           // _timerModel.setRemainingTime() calls notifyListeners via _updateDisplayTime().
        break;
      case AppLifecycleState.inactive:
        print("App Inactive");
        // Potentially pause timer if it's running, to prevent issues if app is killed soon after.
        // However, for background notifications, we might want to let it run until paused/detached.
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        print("App Paused or Detached");
        if (_timerModel.isRunning) {
          _scheduledEndTime = DateTime.now().add(_timerModel.remainingTime);
          _tickTimer?.cancel();
          _tickTimer = null;
          // _timerModel.pauseTimer(); // Keep internal state as running, but stop ticks

          String timerTypeString = "Session";
          switch (_timerModel.currentType) {
            case TimerType.work:
              timerTypeString = "Work";
              break;
            case TimerType.shortBreak:
              timerTypeString = "Short Break";
              break;
            case TimerType.longBreak:
              timerTypeString = "Long Break";
              break;
          }

          _notificationService.scheduleNotification(
            _backgroundNotificationId,
            'Timer Finished!',
            'Your $timerTypeString session is over.',
            _scheduledEndTime!,
          );
          print("App backgrounded. Timer paused. Notification scheduled for $_scheduledEndTime");
        }
        break;
    }
  }
}
