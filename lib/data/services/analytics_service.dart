import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsRecord {
  final String date;
  final int tasksCreated;
  final int tasksCompleted;
  final int focusTimeSeconds;
  final int appUsageTimeSeconds;

  AnalyticsRecord({
    required this.date,
    required this.tasksCreated,
    required this.tasksCompleted,
    required this.focusTimeSeconds,
    required this.appUsageTimeSeconds,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'tasksCreated': tasksCreated,
        'tasksCompleted': tasksCompleted,
        'focusTimeSeconds': focusTimeSeconds,
        'appUsageTimeSeconds': appUsageTimeSeconds,
      };

  factory AnalyticsRecord.fromJson(Map<String, dynamic> json) =>
      AnalyticsRecord(
        date: json['date'] as String,
        tasksCreated: json['tasksCreated'] as int,
        tasksCompleted: json['tasksCompleted'] as int,
        focusTimeSeconds: json['focusTimeSeconds'] as int,
        appUsageTimeSeconds: json['appUsageTimeSeconds'] as int,
      );
}

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  SharedPreferences? _prefs;
  static const String _keyHistory = 'analytics_history_records';
  static const String _keyTodayCreated = 'analytics_today_created';
  static const String _keyTodayCompleted = 'analytics_today_completed';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int getTodayCreated() {
    return _prefs?.getInt(_keyTodayCreated) ?? 0;
  }

  int getTodayCompleted() {
    return _prefs?.getInt(_keyTodayCompleted) ?? 0;
  }

  Future<void> incrementTasksCreated() async {
    final count = getTodayCreated() + 1;
    await _prefs?.setInt(_keyTodayCreated, count);
  }

  Future<void> incrementTasksCompleted() async {
    final count = getTodayCompleted() + 1;
    await _prefs?.setInt(_keyTodayCompleted, count);
  }

  List<AnalyticsRecord> getHistory() {
    final jsonStr = _prefs?.getString(_keyHistory);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((item) =>
              AnalyticsRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> recordDailyStats({
    required String date,
    required int focusTimeSeconds,
    required int appUsageTimeSeconds,
  }) async {
    final history = getHistory();
    final todayCreated = getTodayCreated();
    final todayCompleted = getTodayCompleted();

    history.removeWhere((record) => record.date == date);

    history.add(AnalyticsRecord(
      date: date,
      tasksCreated: todayCreated,
      tasksCompleted: todayCompleted,
      focusTimeSeconds: focusTimeSeconds,
      appUsageTimeSeconds: appUsageTimeSeconds,
    ));

    if (history.length > 30) {
      history.sort((a, b) => a.date.compareTo(b.date));
      while (history.length > 30) {
        history.removeAt(0);
      }
    }

    final jsonStr = jsonEncode(history.map((e) => e.toJson()).toList());
    await _prefs?.setString(_keyHistory, jsonStr);

    await _prefs?.setInt(_keyTodayCreated, 0);
    await _prefs?.setInt(_keyTodayCompleted, 0);
  }
}
