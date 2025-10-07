import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';

import '../models/settings.dart';
import '../models/timer.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     debugPrint('Native called background task: $taskName');
//     if (taskName == 'tickTimer') {
//       final prefs = await SharedPreferences.getInstance();
//       final timerData = prefs.getString('timer_data');
//       if (timerData != null) {
//         final data = jsonDecode(timerData);
//         final endTime = DateTime.parse(data['end_time']);
//         final now = DateTime.now();

//         if (now.isAfter(endTime)) {
//           // 计时器已结束，清除数据
//           await prefs.remove('timer_data');
//         }
//       }
//       return true;
//     }
//     return false;
//   });
// }

class TimerProvider extends ChangeNotifier {
  final TimerModel _timerModel;
  final Settings _settings;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _tickTimer;
  bool _isSoundLoaded = false;
  bool _isCompleted = false;
  DateTime? _endTime;

  TimerProvider({
    required TimerModel timerModel,
    required Settings settings,
  })  : _timerModel = timerModel,
        _settings = settings {
    _loadSound();
    _timerModel.addListener(_onTimerChanged);
    // _initializeWorkmanager();
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final timerData = prefs.getString('timer_data');
    if (timerData != null) {
      final data = jsonDecode(timerData);
      _endTime = DateTime.parse(data['end_time']);
      final remainingSeconds = _endTime!.difference(DateTime.now()).inSeconds;
      if (remainingSeconds > 0) {
        // 如果还有剩余时间，可以选择恢复倒计时（如需自动恢复可保留此逻辑）
        // _timerModel.setSelectedDuration(remainingSeconds ~/ 60);
        // startTimer();
        // 但根据需求，强制退出后不自动恢复，直接重置
        resetTimer();
      } else {
        // 已超时，直接重置
        resetTimer();
        await prefs.remove('timer_data');
      }
    } else {
      // 没有计时器数据，也重置
      resetTimer();
    }
  }

  Future<void> _saveTimerState() async {
    if (_endTime != null) {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'end_time': _endTime!.toIso8601String(),
      };
      await prefs.setString('timer_data', jsonEncode(data));
    }
  }

  // Future<void> _initializeWorkmanager() async {
  //   await Workmanager().initialize(
  //     callbackDispatcher,
  //     isInDebugMode: true,
  //   );
  // }

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
      resetTimer();
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
    _endTime = DateTime.now().add(_timerModel.remainingTime);
    _saveTimerState();

    // 前台用 Timer 实时刷新 UI
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      debugPrint('TimerProvider: tick, 当前时间: ${DateTime.now()}');
      _timerModel.tick();
      if (_timerModel.state == TimerState.finished) {
        timer.cancel();
        _tickTimer = null;
        _endTime = null;
        _saveTimerState();
      }
    });

    notifyListeners();
  }

  void pauseTimer() {
    // debugPrint('TimerProvider: 暂停计时');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.pauseTimer();
    _endTime = null;
    _saveTimerState();
    // 取消后台任务
    // Workmanager().cancelByUniqueName('tickTimer');
    notifyListeners();
  }

  void resetTimer() {
    // debugPrint('TimerProvider: 重置计时器');
    _tickTimer?.cancel();
    _tickTimer = null;
    _timerModel.reset();
    _stopSound();
    _endTime = null;
    _saveTimerState();
    // 取消后台任务
    // Workmanager().cancelByUniqueName('tickTimer');
    notifyListeners();
  }

  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
      debugPrint('TimerProvider: 声音停止成功');
    } catch (e) {
      debugPrint('TimerProvider: 停止声音失败: $e');
    }
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
      // 设置音频播放器为正常模式（不循环）
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setPlaybackRate(1.0);

      // 设置音频会话
      await _audioPlayer.setAudioContext(
        const AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            ],
          ),
          android: AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      // 先停止任何正在播放的声音
      await _audioPlayer.stop();

      // 重新加载声音文件
      await _audioPlayer.setSource(AssetSource('sounds/complete.mp3'));

      // 播放声音（只播放一次）
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
      debugPrint('TimerProvider: 开始播放声音');

      // 可选：监听播放完成事件（不做任何处理）
      _audioPlayer.onPlayerComplete.listen((event) {
        debugPrint('TimerProvider: 播放完成');
      });
    } catch (e) {
      // debugPrint('TimerProvider: 播放声音失败: $e');
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