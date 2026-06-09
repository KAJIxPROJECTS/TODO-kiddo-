import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/data/services/analytics_service.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_background_service/flutter_background_service.dart';

class FocusSessionService with WidgetsBindingObserver {
  static final FocusSessionService _instance = FocusSessionService._internal();
  factory FocusSessionService() => _instance;
  FocusSessionService._internal();

  SharedPreferences? _prefs;
  static const String _keyAccumulatedTime = 'focus_accumulated_seconds';
  static const String _keyDailyUsage = 'focus_daily_usage_seconds';
  static const String _keyDailyFocus = 'focus_daily_focus_seconds';
  static const String _keyLastTrackDate = 'focus_last_track_date';

  int _accumulatedSeconds = 0;
  int _dailyUsageSeconds = 0;
  int _dailyFocusSeconds = 0;
  String _lastTrackDate = '';

  DateTime? _sessionStart;
  Timer? _realtimeTimer;

  bool isFocusSessionActive = false;

  final ValueNotifier<int> totalFocusTimeNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> focusRateNotifier = ValueNotifier<int>(0);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _accumulatedSeconds = _prefs?.getInt(_keyAccumulatedTime) ?? 0;
    _dailyUsageSeconds = _prefs?.getInt(_keyDailyUsage) ?? 0;
    _dailyFocusSeconds = _prefs?.getInt(_keyDailyFocus) ?? 0;
    _lastTrackDate = _prefs?.getString(_keyLastTrackDate) ?? _getTodayDateString();

    _checkDailyReset();

    totalFocusTimeNotifier.value = _accumulatedSeconds;
    _updateFocusRateNotifier();

    WidgetsBinding.instance.addObserver(this);
    _startSession();
    await initializeBackgroundService();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _checkDailyReset() {
    final today = _getTodayDateString();
    if (_lastTrackDate != today) {
      _persistTime();
      AnalyticsService().recordDailyStats(
        date: _lastTrackDate,
        focusTimeSeconds: _dailyFocusSeconds,
        appUsageTimeSeconds: _dailyUsageSeconds,
      );
      _dailyUsageSeconds = 0;
      _dailyFocusSeconds = 0;
      _lastTrackDate = today;
      _prefs?.setInt(_keyDailyUsage, 0);
      _prefs?.setInt(_keyDailyFocus, 0);
      _prefs?.setString(_keyLastTrackDate, today);
      _updateFocusRateNotifier();
    }
  }

  void _updateFocusRateNotifier() {
    if (_dailyUsageSeconds == 0) {
      focusRateNotifier.value = 0;
    } else {
      final rate = (_dailyFocusSeconds * 100) ~/ _dailyUsageSeconds;
      focusRateNotifier.value = rate > 100 ? 100 : rate;
    }
  }

  void setFocusSessionActive(bool active) {
    if (isFocusSessionActive != active) {
      _persistTime();
      isFocusSessionActive = active;
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (active) {
          FlutterBackgroundService().startService();
        } else {
          FlutterBackgroundService().invoke('stopService');
        }
      }
    }
  }

  void _startSession() {
    _sessionStart = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _realtimeTimer?.cancel();
    _realtimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkDailyReset();
      if (_sessionStart != null) {
        final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
        totalFocusTimeNotifier.value = _accumulatedSeconds + elapsed;
        
        final newDailyUsage = _dailyUsageSeconds + elapsed;
        final newDailyFocus = _dailyFocusSeconds + (isFocusSessionActive ? elapsed : 0);
        
        if (newDailyUsage == 0) {
          focusRateNotifier.value = 0;
        } else {
          final rate = (newDailyFocus * 100) ~/ newDailyUsage;
          focusRateNotifier.value = rate > 100 ? 100 : rate;
        }
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
      _dailyUsageSeconds += elapsed;
      if (isFocusSessionActive) {
        _dailyFocusSeconds += elapsed;
      }
      _sessionStart = DateTime.now();
      _prefs?.setInt(_keyAccumulatedTime, _accumulatedSeconds);
      _prefs?.setInt(_keyDailyUsage, _dailyUsageSeconds);
      _prefs?.setInt(_keyDailyFocus, _dailyFocusSeconds);
      _prefs?.setString(_keyLastTrackDate, _lastTrackDate);
      totalFocusTimeNotifier.value = _accumulatedSeconds;
      _updateFocusRateNotifier();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDailyReset();
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final title = prefs.getString('current_focus_task_title') ?? 'Active Task';

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: 'Focus Session Active',
      content: title,
    );
  }
}

Future<void> initializeBackgroundService() async {
  if (kIsWeb) return;
  if (!Platform.isAndroid && !Platform.isIOS) return;

  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'focus_foreground',
      initialNotificationTitle: 'Focus Session Active',
      initialNotificationContent: 'Active Task',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}
