import 'dart:async';

import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import 'settings.dart';

enum TimerState { initial, running, paused, finished }

enum TimerType { work, shortBreak, longBreak }

class TimerHistory {
  final DateTime timestamp;
  final TimerType type;
  final int durationMinutes;
  final int actualDurationSeconds; // 实际持续时间（秒）

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
  Settings settings;
  final NotificationService _notificationService = NotificationService();

  Timer? _timer;
  TimerState _state = TimerState.initial;
  TimerType _currentType = TimerType.work;
  int _currentSession = 1;
  int _totalCompletedSessions = 0;
  Duration _remainingTime = const Duration(minutes: 25);
  Duration _totalTime = const Duration(minutes: 25);
  List<TimerHistory> _history = [];
  bool _hasStarted = false; // 追踪当前计时器是否已经开始过

  TimerModel({required this.settings}) {
    _resetTimer();
  }

  // 更新设置
  void updateSettings(Settings newSettings) {
    settings = newSettings;
    onSettingsUpdated();
  }

  // 添加设置更新监听器
  void onSettingsUpdated() {
    // 如果计时器正在运行，先停止它
    _timer?.cancel();
    _state = TimerState.initial;
    _hasStarted = false;

    // 根据当前计时器类型重置时间
    _setTimerDuration();

    notifyListeners();
  }

  TimerState get state => _state;
  TimerType get currentType => _currentType;
  int get currentSession => _currentSession;
  int get sessionsBeforeLongBreak => settings.sessionsBeforeLongBreak;
  int get totalCompletedSessions => _totalCompletedSessions;
  Duration get remainingTime => _remainingTime;
  Duration get totalTime => _totalTime;
  List<TimerHistory> get history => _history;

  double get progress {
    if (_totalTime.inSeconds == 0) return 0;
    final elapsed = _totalTime.inSeconds - _remainingTime.inSeconds;
    return elapsed / _totalTime.inSeconds;
  }

  void startTimer() {
    if (_state == TimerState.running) return;

    _state = TimerState.running;
    _hasStarted = true; // 标记计时器已开始
    _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
    notifyListeners();
  }

  void pauseTimer() {
    if (_state != TimerState.running) return;

    _state = TimerState.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    _resetTimer();
    _hasStarted = false; // 重置时清除开始状态
    notifyListeners();
  }

  void skipToNext() {
    // 临时保存当前状态，用于判断是否需要记录历史
    final wasStarted = _hasStarted;
    final currentType = _currentType;

    if (_currentType == TimerType.work) {
      _completeWorkSession(wasStarted);
    } else {
      _completeBreak(wasStarted && currentType == TimerType.longBreak);
    }

    _state = TimerState.initial;
    _hasStarted = false; // 重置开始状态
    notifyListeners();
  }

  void _timerCallback(Timer timer) {
    if (_remainingTime.inSeconds <= 1) {
      // Timer completed
      if (_currentType == TimerType.work) {
        _completeWorkSession(true); // 计时结束，肯定已经开始过
      } else {
        _completeBreak(_currentType == TimerType.longBreak); // 只记录长休息
      }
    } else {
      _remainingTime = _remainingTime - const Duration(seconds: 1);
    }
    notifyListeners();
  }

  void _resetTimer() {
    _timer?.cancel();
    _state = TimerState.initial;

    _setTimerDuration();
  }

  void _setTimerDuration() {
    switch (_currentType) {
      case TimerType.work:
        _remainingTime = Duration(minutes: settings.workDurationMinutes);
        _totalTime = _remainingTime;
        break;
      case TimerType.shortBreak:
        _remainingTime = Duration(minutes: settings.shortBreakDurationMinutes);
        _totalTime = _remainingTime;
        break;
      case TimerType.longBreak:
        _remainingTime = Duration(minutes: settings.longBreakDurationMinutes);
        _totalTime = _remainingTime;
        break;
    }
  }

  void _completeWorkSession(bool addToHistory) {
    _timer?.cancel();
    _state = TimerState.finished;

    // 添加通知
    if (settings.notificationsEnabled) {
      final nextBreakType =
          _currentSession >= settings.sessionsBeforeLongBreak ? "长休息" : "短休息";
      _notificationService.showWorkSessionCompleted(
        "工作阶段完成，现在开始$nextBreakType！",
      );
    }

    // 只有当计时器已经开始过时才添加到历史记录
    if (addToHistory) {
      // 计算实际持续的时间
      final int actualDurationSeconds =
          _totalTime.inSeconds - _remainingTime.inSeconds;

      // Add to history
      _history.add(
        TimerHistory(
          timestamp: DateTime.now(),
          type: TimerType.work,
          durationMinutes: settings.workDurationMinutes,
          actualDurationSeconds: actualDurationSeconds,
        ),
      );

      _totalCompletedSessions++;
    }

    // Determine next break type
    if (_currentSession >= settings.sessionsBeforeLongBreak) {
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

    // 添加通知
    if (settings.notificationsEnabled) {
      final message =
          _currentType == TimerType.longBreak
              ? "长休息结束，开始新的工作阶段！"
              : "短休息结束，开始新的工作阶段！";
      _notificationService.showBreakCompleted(message);
    }

    // 只有需要添加到历史记录时才添加
    if (addToHistory) {
      final int actualDurationSeconds =
          _totalTime.inSeconds - _remainingTime.inSeconds;

      // Add to history
      _history.add(
        TimerHistory(
          timestamp: DateTime.now(),
          type: _currentType, // 使用当前类型
          durationMinutes:
              _currentType == TimerType.longBreak
                  ? settings.longBreakDurationMinutes
                  : settings.shortBreakDurationMinutes,
          actualDurationSeconds: actualDurationSeconds,
        ),
      );
    }

    // Next session is always work
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
