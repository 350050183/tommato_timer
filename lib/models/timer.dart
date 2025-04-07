import 'package:flutter/foundation.dart';

import '../models/settings.dart';

enum TimerState { initial, running, paused, finished }

class TimerModel extends ChangeNotifier {
  final Settings _settings;
  bool _isCompleted = false;
  bool _isRunning = false;
  int _selectedDuration = 25; // 当前选择的时间（分钟）
  int _remainingSeconds = 25 * 60; // 初始时间25分钟
  TimerState _state = TimerState.initial;

  TimerModel({required Settings settings}) : _settings = settings {
    debugPrint('TimerModel: 初始化，默认时间25分钟');
  }

  Settings get settings => _settings;
  bool get isCompleted => _isCompleted;
  bool get isRunning => _isRunning;
  TimerState get state => _state;
  Duration get remainingTime {
    debugPrint('TimerModel: 获取剩余时间 - $_remainingSeconds 秒');
    return Duration(seconds: _remainingSeconds);
  }

  int get selectedDuration => _selectedDuration;
  double get progress => 1 - (_remainingSeconds / (_selectedDuration * 60));

  void setSelectedDuration(int minutes) {
    debugPrint('TimerModel: 设置选择的时间: $minutes 分钟');
    _selectedDuration = minutes;
    if (!_isRunning) {
      debugPrint('TimerModel: 计时器未运行，更新剩余时间为: ${minutes * 60} 秒');
      _remainingSeconds = minutes * 60;
      _state = TimerState.initial;
      notifyListeners();
    } else {
      debugPrint('TimerModel: 计时器运行中，不更新剩余时间');
    }
  }

  void startTimer() {
    if (_isRunning) {
      debugPrint('TimerModel: 计时器已经在运行');
      return;
    }
    debugPrint('TimerModel: 开始计时器，初始时间: $_remainingSeconds 秒');
    _isRunning = true;
    _isCompleted = false;
    _state = TimerState.running;
    notifyListeners();
  }

  void pauseTimer() {
    debugPrint('TimerModel: 暂停计时器，当前剩余时间: $_remainingSeconds 秒');
    _isRunning = false;
    _state = TimerState.paused;
    notifyListeners();
  }

  void reset() {
    debugPrint('TimerModel: 重置计时器，重置为: ${_selectedDuration * 60} 秒');
    _remainingSeconds = _selectedDuration * 60;
    _isRunning = false;
    _isCompleted = false;
    _state = TimerState.initial;
    notifyListeners();
  }

  void tick() {
    if (_isRunning && _remainingSeconds > 0) {
      debugPrint('TimerModel: 计时器正在运行，当前剩余时间: $_remainingSeconds 秒');
      _remainingSeconds--;
      debugPrint('TimerModel: 更新后剩余时间: $_remainingSeconds 秒');
      if (_remainingSeconds == 0) {
        debugPrint('TimerModel: 计时器完成');
        _isCompleted = true;
        _isRunning = false;
        _state = TimerState.finished;
      }
      notifyListeners();
    } else {
      debugPrint(
          'TimerModel: 计时器未运行或已结束，_isRunning: $_isRunning, _remainingSeconds: $_remainingSeconds');
    }
  }

  void skipToNext() {
    debugPrint('TimerModel: 跳到下一个');
    _remainingSeconds = _selectedDuration * 60;
    _isRunning = false;
    _isCompleted = true;
    _state = TimerState.finished;
    notifyListeners();
  }
}
