import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusSessionService with WidgetsBindingObserver {
  static final FocusSessionService _instance = FocusSessionService._internal();
  factory FocusSessionService() => _instance;
  FocusSessionService._internal();

  SharedPreferences? _prefs;
  static const String _keyAccumulatedTime = 'focus_accumulated_seconds';
  
  int _accumulatedSeconds = 0;
  DateTime? _sessionStart;
  Timer? _realtimeTimer;

  final ValueNotifier<int> totalFocusTimeNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _accumulatedSeconds = _prefs?.getInt(_keyAccumulatedTime) ?? 0;
    totalFocusTimeNotifier.value = _accumulatedSeconds;

    WidgetsBinding.instance.addObserver(this);
    _startSession();
  }

  void _startSession() {
    _sessionStart = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sessionStart != null) {
        final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
        totalFocusTimeNotifier.value = _accumulatedSeconds + elapsed;
      }
    });
  }

  void _stopTimer() {
    _realtimeTimer?.cancel();
    _realtimeTimer = null;
  }

  void _persistTime() {
    if (_sessionStart != null) {
      final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
      _accumulatedSeconds += elapsed;
      _sessionStart = DateTime.now();
      _prefs?.setInt(_keyAccumulatedTime, _accumulatedSeconds);
      totalFocusTimeNotifier.value = _accumulatedSeconds;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sessionStart = DateTime.now();
      _startTimer();
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.inactive || 
               state == AppLifecycleState.detached) {
      _persistTime();
      _stopTimer();
      _sessionStart = null;
    }
  }
  
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
  }
}
