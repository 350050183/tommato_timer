import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import 'settings.dart';

enum TimerState { initial, running, paused, finished }

enum TimerType { work, shortBreak, longBreak }

class TimerHistory {
  final DateTime timestamp;
  final TimerType type;
  final int durationMinutes;
  final int actualDurationSeconds;

  TimerHistory({
    required this.timestamp,
    required this.type,
    required this.durationMinutes,
    required this.actualDurationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'durationMinutes': durationMinutes,
      'actualDurationSeconds': actualDurationSeconds,
    };
  }

  factory TimerHistory.fromJson(Map<String, dynamic> json) {
    return TimerHistory(
      timestamp: DateTime.parse(json['timestamp']),
      type: TimerType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TimerType.work,
      ),
      durationMinutes: json['durationMinutes'],
      actualDurationSeconds: json['actualDurationSeconds'] ?? 0,
    );
  }
}

class TimerModel extends ChangeNotifier {
  final Settings _settings;
  final NotificationService _notificationService = NotificationService();

  Timer? _timer;
  TimerState _state = TimerState.initial;
  TimerType _currentType = TimerType.work;
  int _currentSession = 1;
  int _totalCompletedSessions = 0;
  Duration _remainingTime = const Duration(minutes: 25);
  Duration _totalTime = const Duration(minutes: 25);
  List<TimerHistory> _history = [];
  bool _hasStarted = false;
  bool _isRunning = false;
  int _currentSide = 0;
  String _displayTime = '00:00';

  TimerModel({required Settings settings}) : _settings = settings {
    debugPrint('初始化 TimerModel');
    _remainingTime = const Duration(minutes: 25);
    _totalTime = _remainingTime;
    _updateDisplayTime();
  }

  Settings get settings => _settings;
  TimerState get state => _state;
  TimerType get currentType => _currentType;
  int get currentSession => _currentSession;
  int get totalCompletedSessions => _totalCompletedSessions;
  Duration get remainingTime => _remainingTime;
  Duration get totalTime => _totalTime;
  List<TimerHistory> get history => _history;
  bool get isRunning => _isRunning;
  int get currentSide => _currentSide;
  String get displayTime => _displayTime;

  double get progress {
    if (_totalTime.inSeconds == 0) return 0;
    final elapsed = _totalTime.inSeconds - _remainingTime.inSeconds;
    final progress = elapsed / _totalTime.inSeconds;
    debugPrint(
        '计算进度: 总时间=${_totalTime.inSeconds}秒, 剩余时间=${_remainingTime.inSeconds}秒, 已用时间=$elapsed秒, 进度=$progress');
    return progress;
  }

  void setCurrentSide(int side) {
    debugPrint('设置当前面: 从 $_currentSide 到 $side');
    if (_currentSide != side) {
      _currentSide = side;
      notifyListeners();
    }
  }

  void _updateDisplayTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remainingTime.inMinutes);
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));
    _displayTime = '$minutes:$seconds';
    debugPrint('更新显示时间: $_displayTime (剩余${_remainingTime.inSeconds}秒)');
    notifyListeners();
  }

  void startTimer() {
    if (!_isRunning) {
      debugPrint(
          '开始计时: 状态=${_state}, 类型=${_currentType}, 剩余时间=${_remainingTime.inMinutes}分钟');
      _isRunning = true;
      _hasStarted = true;
      _state = TimerState.running;
      notifyListeners();
    }
  }

  void tick() {
    if (!_isRunning) return;

    debugPrint('计时器tick: 剩余时间=${_remainingTime.inSeconds}秒, 运行状态=$_isRunning');
    if (_remainingTime.inSeconds <= 1) {
      debugPrint('计时结束');
      if (_currentType == TimerType.work) {
        _completeWorkSession(true);
      } else {
        _completeBreak(_currentType == TimerType.longBreak);
      }
      _hasStarted = false;
      pauseTimer();
    } else {
      _remainingTime = _remainingTime - const Duration(seconds: 1);
      debugPrint(
          '计时进行中: 剩余${_remainingTime.inMinutes}分钟${_remainingTime.inSeconds % 60}秒');
      _updateDisplayTime();
      notifyListeners();
    }
  }

  void pauseTimer() {
    if (_isRunning) {
      debugPrint(
          '停止计时: 状态=${_state}, 剩余时间=${_remainingTime.inMinutes}分钟${_remainingTime.inSeconds % 60}秒');
      _isRunning = false;
      _state = TimerState.paused;
      notifyListeners();
    }
  }

  void reset() {
    debugPrint('重置计时器: 当前状态=${_state}');
    pauseTimer();
    _hasStarted = false;
    _state = TimerState.initial;
    _remainingTime = const Duration(minutes: 25);
    _totalTime = _remainingTime;
    debugPrint('重置后: 状态=${_state}, 剩余时间=${_remainingTime.inMinutes}分钟');
    _updateDisplayTime();
    notifyListeners();
  }

  void skipToNext() {
    final wasStarted = _hasStarted;
    final currentType = _currentType;

    if (_currentType == TimerType.work) {
      _completeWorkSession(wasStarted);
    } else {
      _completeBreak(wasStarted && currentType == TimerType.longBreak);
    }

    _state = TimerState.initial;
    _hasStarted = false;
    notifyListeners();
  }

  void _timerCallback(Timer timer) {
    debugPrint('定时器回调开始: 剩余时间=${_remainingTime.inSeconds}秒, 运行状态=$_isRunning');
    if (_remainingTime.inSeconds <= 1) {
      debugPrint('计时结束');
      if (_currentType == TimerType.work) {
        _completeWorkSession(true);
      } else {
        _completeBreak(_currentType == TimerType.longBreak);
      }
      _hasStarted = false;
      pauseTimer();
    } else {
      _remainingTime = _remainingTime - const Duration(seconds: 1);
      debugPrint(
          '计时进行中: 剩余${_remainingTime.inMinutes}分钟${_remainingTime.inSeconds % 60}秒');
      _updateDisplayTime();
    }
    notifyListeners();
  }

  void _resetTimer() {
    _timer?.cancel();
    _state = TimerState.initial;
    _setTimerDuration();
  }

  void _setTimerDuration() {
    debugPrint('设置计时器时长: 当前类型=$_currentType');
    switch (_currentType) {
      case TimerType.work:
        _remainingTime = const Duration(minutes: 25);
        _totalTime = _remainingTime;
        break;
      case TimerType.shortBreak:
        _remainingTime = const Duration(minutes: 5);
        _totalTime = _remainingTime;
        break;
      case TimerType.longBreak:
        _remainingTime = const Duration(minutes: 15);
        _totalTime = _remainingTime;
        break;
    }
    debugPrint(
        '计时器时长已设置: 总时间=${_totalTime.inMinutes}分钟, 剩余时间=${_remainingTime.inMinutes}分钟');
  }

  void _completeWorkSession(bool addToHistory) {
    _timer?.cancel();
    _state = TimerState.finished;

    if (settings.notificationsEnabled) {
      final nextBreakType = _currentSession >= 4 ? "长休息" : "短休息";
      _notificationService.showWorkSessionCompleted(
        "工作阶段完成，现在开始$nextBreakType！",
      );
    }

    if (addToHistory) {
      final int actualDurationSeconds =
          _totalTime.inSeconds - _remainingTime.inSeconds;

      _history.add(
        TimerHistory(
          timestamp: DateTime.now(),
          type: TimerType.work,
          durationMinutes: 25,
          actualDurationSeconds: actualDurationSeconds,
        ),
      );

      _totalCompletedSessions++;
    }

    if (_currentSession >= 4) {
      _currentType = TimerType.longBreak;
      _currentSession = 1;
    } else {
      _currentType = TimerType.shortBreak;
      _currentSession++;
    }

    _setTimerDuration();
  }

  void _completeBreak(bool addToHistory) {
    _timer?.cancel();
    _state = TimerState.finished;

    if (settings.notificationsEnabled) {
      final message = _currentType == TimerType.longBreak
          ? "长休息结束，开始新的工作阶段！"
          : "短休息结束，开始新的工作阶段！";
      _notificationService.showBreakCompleted(message);
    }

    if (addToHistory) {
      final int actualDurationSeconds =
          _totalTime.inSeconds - _remainingTime.inSeconds;

      _history.add(
        TimerHistory(
          timestamp: DateTime.now(),
          type: _currentType,
          durationMinutes: _currentType == TimerType.longBreak ? 15 : 5,
          actualDurationSeconds: actualDurationSeconds,
        ),
      );
    }

    _currentType = TimerType.work;
    _setTimerDuration();
  }

  void clearHistory() {
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
